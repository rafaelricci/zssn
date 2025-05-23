require 'rails_helper'

RSpec.describe Api::V1::InfectionReportsController, type: :request do
  let(:reporter) { create(:survivor) }
  let(:reported) { create(:survivor) }
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  describe "POST /api/v1/infection_reports" do
    context "with valid parameters" do
      before do
        post api_v1_infection_reports_path,
             params: {
               infection_report: {
                 reporter_id: reporter.id,
                 reported_id: reported.id
               }
             }.to_json,
             headers: headers
      end

      it "returns 201 Created" do
        expect(response).to have_http_status(:created)
      end

      it "returns the correct JSON structure" do
        json = JSON.parse(response.body)

        expect(json).to eq(
          {
            "reporter_id" => reporter.id,
            "reported" => {
              "id" => reported.id,
              "reports_from_reported_count" => 1
            }
          }
        )
      end
    end

    context "when reporter reports same survivor twice" do
      before do
        create(:infection_report, reporter: reporter, reported: reported)

        post api_v1_infection_reports_path,
             params: {
               infection_report: {
                 reporter_id: reporter.id,
                 reported_id: reported.id
               }
             }.to_json,
             headers: headers
      end
      it "returns 422 Unprocessable Entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns the correct error message" do
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end
end
