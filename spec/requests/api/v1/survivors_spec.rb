require 'rails_helper'

RSpec.describe Api::V1::SurvivorsController, type: :request do
  let(:valid_attributes) { attributes_for(:survivor) }
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  describe "POST /api/v1/survivors" do
    context "with valid parameters" do
      before do
        post api_v1_survivors_path, params: { survivor: valid_attributes }.to_json, headers: headers
      end

      it "creates a new Survivor and returns 201" do
        expect(response).to have_http_status(:created)
      end

      it "returns the created survivor" do
        expect(JSON.parse(response.body)).to include("survivor")
      end

      it "returns the survivor with last_location" do
        json = JSON.parse(response.body)
        expect(json["survivor"]["last_location"]).not_to be_nil
      end
    end

    context "with missing parameters" do
      before do
        post api_v1_survivors_path, params: { survivor: { name: "Alice" } }.to_json, headers: headers
      end

      it "returns 422 with error messages" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages for missing parameters" do
        expect(JSON.parse(response.body)).to include("errors")
      end
    end
  end

  describe "PATCH /api/v1/survivors/:id" do
    let!(:survivor) { Survivor.create!(valid_attributes) }
    let(:lat) { Faker::Address.latitude }
    let(:lon) { Faker::Address.longitude }

    context "with valid location parameters" do
      before do
        patch api_v1_survivor_path(survivor.id),
              params: { survivor: { lat: lat, lon: lon } }.to_json,
              headers: headers
      end

      it "updates lat/lon and returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns lat updated" do
        json = JSON.parse(response.body)
        expect(json["survivor"]["lat"]).to eq(lat)
      end

      it "returns lon updated" do
        json = JSON.parse(response.body)
        expect(json["survivor"]["lon"]).to eq(lon)
      end

      it "return last_location not nil" do
        json = JSON.parse(response.body)
        expect(json["survivor"]["last_location"]).not_to be_nil
      end
    end

    context "with invalid parameters" do
      before do
        patch api_v1_survivor_path(survivor.id),
              params: { survivor: { lat: nil, lon: nil } }.to_json,
              headers: headers
      end

      it "returns 422 with error messages" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages for invalid parameters" do
        expect(JSON.parse(response.body)).to include("errors")
      end
    end
  end
end
