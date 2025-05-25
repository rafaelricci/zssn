require 'rails_helper'

RSpec.describe Api::V1::TradesController, type: :request do
  let(:headers) do
    {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end

  let(:offerer) { create(:survivor) }
  let(:receiver)   { create(:survivor) }

  describe "POST /api/v1/trade" do
    context "when trade is valid" do
      before do
        offerer.inventories.find_by(kind: :water).update!(quantity: 2)
        receiver.inventories.find_by(kind: :medicine).update!(quantity: 4)

        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            offerer_id: offerer.id,
            receiver_id: receiver.id,
            offer_items: { water: 2 },
            request_items: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 200 and updated inventories" do
        expect(response).to have_http_status(:ok)
      end

      it "returns body with correct structure" do
        json = JSON.parse(response.body)

        expect(json).to eq(
          "receiver" => {
            "id" => receiver.id,
            "inventory" => {
              "water" => 2,
              "food" => 0,
              "medicine" => 0,
              "ammo" => 0
            }
          },
          "offerer" => {
            "id" => offerer.id,
            "inventory" => {
              "water" => 0,
              "food" => 0,
              "medicine" => 4,
              "ammo" => 0
            }
          }
        )
      end
    end

    context "when trade is unbalanced" do
      before do
        offerer.inventories.find_by(kind: :water).update!(quantity: 1)
        receiver.inventories.find_by(kind: :medicine).update!(quantity: 3)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            offerer_id: offerer.id,
            receiver_id: receiver.id,
            offer_items: { water: 1 },
            request_items: { medicine: 3 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("Unfair trade. Point values must match")
      end
    end

    context "when survivor is infected" do
      before do
        offerer.inventories.find_by(kind: :water).update!(quantity: 2)
        receiver.inventories.find_by(kind: :medicine).update!(quantity: 4)
        create_list(:infection_report, 3, reported: offerer)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            offerer_id: offerer.id,
            receiver_id: receiver.id,
            offer_items: { water: 2 },
            request_items: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to match(/infected/i)
      end
    end

    context "when survivor does not have enough items" do
      before do
        offerer.inventories.find_by(kind: :water).update!(quantity: 1)
        receiver.inventories.find_by(kind: :medicine).update!(quantity: 4)
         post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            offerer_id: offerer.id,
            receiver_id: receiver.id,
            offer_items: { water: 2 },
            request_items: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("Cannot remove more than available")
      end
    end

    context "when survivor tries to trade with themselves" do
      before do
        offerer.inventories.find_by(kind: :water).update!(quantity: 2)
        offerer.inventories.find_by(kind: :medicine).update!(quantity: 4)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            offerer_id: offerer.id,
            receiver_id: offerer.id,
            offer_items: { water: 2 },
            request_items: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("Cannot trade with yourself")
      end
    end

    context "when from_id is invalid" do
      before do
        offerer.inventories.find_by(kind: :water).update!(quantity: 2)
        receiver.inventories.find_by(kind: :medicine).update!(quantity: 4)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            offerer_id: 99999,
            receiver_id: receiver.id,
            offer_items: { water: 2 },
            request_items: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("Not Found")
      end
    end

    context "when to_id is invalid" do
      before do
        offerer.inventories.find_by(kind: :water).update!(quantity: 2)
        receiver.inventories.find_by(kind: :medicine).update!(quantity: 4)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            offerer_id: offerer.id,
            receiver_id: 99999,
            offer_items: { water: 2 },
            request_items: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 404" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("Not Found")
      end
    end
  end
end
