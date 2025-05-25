require 'rails_helper'

RSpec.describe Api::V1::InfectionReportsController, type: :request do
  let(:reporter) { create(:survivor) }
  let(:reported) { create(:survivor) }
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  describe "POST /api/v1/infection_reports" do
    context "when the infection report is valid" do
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

      it "returns status 201 (created)" do
        expect(response).to have_http_status(:created)
      end

      it "returns the expected JSON response" do
        json = JSON.parse(response.body)

        expect(json).to eq(
          {
            "reporter_id" => reporter.id,
            "reported" => {
              "id" => reported.id,
              "reports_received_count" => 1
            }
          }
        )
      end
    end

    context "when the reporter submits a duplicate report for the same survivor" do
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

      it "returns status 422 (unprocessable entity)" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "includes an error message in the response" do
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end
end
