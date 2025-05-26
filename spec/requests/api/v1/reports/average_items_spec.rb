require "rails_helper"

RSpec.describe Api::V1::Reports::AverageItemsController, type: :request do
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  describe "GET /api/v1/reports/average_items" do
    context "when the request is successful" do
      before do
        survivor1 = create(:survivor)
        survivor2 = create(:survivor)
        survivor1.inventories.find_by(kind: "water").update!(quantity: 2)
        survivor2.inventories.find_by(kind: "water").update!(quantity: 4)

        get api_v1_reports_average_items_path, headers: headers
      end

      it "returns HTTP status 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the correct average for water" do
        expect(JSON.parse(response.body)["averages"]["water"]).to eq(3.0)
      end
    end

    context "when the service fails" do
      before do
        allow(Reports::AverageItemsService).to receive(:call)
          .and_return(ApplicationServiceResult.new(success: false, error: "unexpected error"))

        get api_v1_reports_average_items_path, headers: headers
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
