require 'rails_helper'

RSpec.describe Api::V1::SurvivorsController, type: :request do
  let(:valid_attributes) { attributes_for(:survivor) }
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  describe "POST /api/v1/survivors" do
    context "when the request parameters are valid" do
      before do
        post api_v1_survivors_path, params: { survivor: valid_attributes }.to_json, headers: headers
      end

      it "returns status 201 (created)" do
        expect(response).to have_http_status(:created)
      end

      it "includes the created survivor in the response" do
        expect(JSON.parse(response.body)).to include("survivor")
      end
    end

    context "when required parameters are missing" do
      before do
        post api_v1_survivors_path, params: { survivor: { name: "Alice" } }.to_json, headers: headers
      end

      it "returns status 422 (unprocessable entity)" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "includes error messages in the response" do
        expect(JSON.parse(response.body)).to include("errors")
      end
    end
  end

  describe "PATCH /api/v1/survivors/:id" do
    let!(:survivor) { Survivor.create!(valid_attributes) }
    let(:latitude) { Faker::Address.latitude }
    let(:longitude) { Faker::Address.longitude }

    context "when updating with valid location parameters" do
      before do
        patch api_v1_survivor_path(survivor.id),
              params: { survivor: { latitude: latitude, longitude: longitude } }.to_json,
              headers: headers
      end

      it "returns status 200 (ok)" do
        expect(response).to have_http_status(:ok)
      end

      it "updates the latitude field" do
        json = JSON.parse(response.body)
        expect(json["survivor"]["latitude"]).to eq(latitude)
      end

      it "updates the longitude field" do
        json = JSON.parse(response.body)
        expect(json["survivor"]["longitude"]).to eq(longitude)
      end
    end

    context "when updating with invalid location parameters" do
      before do
        patch api_v1_survivor_path(survivor.id),
              params: { survivor: { latitude: nil, longitude: nil } }.to_json,
              headers: headers
      end

      it "returns status 422 (unprocessable entity)" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "includes validation error messages in the response" do
        expect(JSON.parse(response.body)).to include("errors")
      end
    end

    context "when the survivor has been marked as infected" do
      before do
        create_list(:infection_report, 3, reported: survivor)
        patch api_v1_survivor_path(survivor.id),
              params: { survivor: { latitude: latitude, longitude: longitude } }.to_json,
              headers: headers
      end

      it "returns status 422 (unprocessable entity)" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "includes an error message indicating the survivor cannot be updated" do
        expect(JSON.parse(response.body)).to include("errors")
      end
    end
  end
end
