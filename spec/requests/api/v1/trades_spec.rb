require 'rails_helper'

RSpec.describe Api::V1::TradesController, type: :request do
  let(:headers) do
    {
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end

  let(:from_survivor) { create(:survivor) }
  let(:to_survivor)   { create(:survivor) }

  describe "POST /api/v1/trade" do
    context "when trade is valid" do
      before do
        from_survivor.inventories.find_by(kind: :water).update!(quantity: 2)
        to_survivor.inventories.find_by(kind: :medicine).update!(quantity: 4)

        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            from_id: from_survivor.id,
            to_id: to_survivor.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 200 and updated inventories" do
        expect(response).to have_http_status(:ok)
      end

      it "returns body with correct structure" do
        json = JSON.parse(response.body)

        expect(json).to eq(
          "requester" => {
            "id" => from_survivor.id,
            "inventory" => {
              "water" => 0,
              "food" => 0,
              "medicine" => 4,
              "ammo" => 0
            }
          },
          "offerer" => {
            "id" => to_survivor.id,
            "inventory" => {
              "water" => 2,
              "food" => 0,
              "medicine" => 0,
              "ammo" => 0
            }
          }
        )
      end
    end

    context "when trade is unbalanced" do
      before do
        from_survivor.inventories.find_by(kind: :water).update!(quantity: 1)
        to_survivor.inventories.find_by(kind: :medicine).update!(quantity: 3)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            from_id: from_survivor.id,
            to_id: to_survivor.id,
            offer: { water: 1 },
            request: { medicine: 3 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to match(/must be balanced/i)
      end
    end

    context "when survivor is infected" do
      before do
        from_survivor.inventories.find_by(kind: :water).update!(quantity: 2)
        to_survivor.inventories.find_by(kind: :medicine).update!(quantity: 4)
        create_list(:infection_report, 3, reported: from_survivor)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            from_id: from_survivor.id,
            to_id: to_survivor.id,
            offer: { water: 2 },
            request: { medicine: 4 }
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
        from_survivor.inventories.find_by(kind: :water).update!(quantity: 1)
        to_survivor.inventories.find_by(kind: :medicine).update!(quantity: 4)
         post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            from_id: from_survivor.id,
            to_id: to_survivor.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to match(/not have enough/i)
      end
    end

    context "when survivor tries to trade with themselves" do
      before do
        from_survivor.inventories.find_by(kind: :water).update!(quantity: 2)
        from_survivor.inventories.find_by(kind: :medicine).update!(quantity: 4)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            from_id: from_survivor.id,
            to_id: from_survivor.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to match(/cannot trade with themselves/i)
      end
    end

    context "when from_id is invalid" do
      before do
        from_survivor.inventories.find_by(kind: :water).update!(quantity: 2)
        to_survivor.inventories.find_by(kind: :medicine).update!(quantity: 4)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            from_id: 99999,
            to_id: to_survivor.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("Couldn't find Survivor with 'id'=99999")
      end
    end

    context "when to_id is invalid" do
      before do
        from_survivor.inventories.find_by(kind: :water).update!(quantity: 2)
        to_survivor.inventories.find_by(kind: :medicine).update!(quantity: 4)
        post "/api/v1/trade", params: payload, headers: headers
      end

      let(:payload) do
        {
          trade: {
            from_id: from_survivor.id,
            to_id: 99999,
            offer: { water: 2 },
            request: { medicine: 4 }
          }
        }.to_json
      end

      it "returns status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        expect(JSON.parse(response.body)["error"]).to eq("Couldn't find Survivor with 'id'=99999")
      end
    end
  end
end
