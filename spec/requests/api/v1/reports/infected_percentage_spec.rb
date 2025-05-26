require "rails_helper"

RSpec.describe Api::V1::Reports::InfectedPercentageController, type: :request do
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  describe "GET /api/v1/reports/infected_percentage" do
    context "when the request is successful" do
      before do
        infected = create(:survivor)
        create_list(:infection_report, 3, reported: infected)

        get api_v1_reports_infected_percentage_index_path, headers: headers
      end

      it "returns HTTP status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the correct infected percentage" do
        expect(JSON.parse(response.body)).to include("percentage" => 25.0)
      end
    end

    context "when the service fails" do
      before do
        allow(Reports::InfectedPercentageService).to receive(:call)
          .and_return(ApplicationServiceResult.new(success: false, error: "unexpected error"))

        get api_v1_reports_infected_percentage_index_path, headers: headers
      end

      it "returns HTTP status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns the error message" do
        expect(JSON.parse(response.body)).to eq("error" => "unexpected error")
      end
    end
  end
end
