require 'rails_helper'

RSpec.describe Api::V1::InventoriesController, type: :request do
  let(:survivor) { create(:survivor) }
  let(:inventory_kind) { Inventory.kinds.keys.sample }
  let(:headers) { { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" } }

  describe "PATCH /api/v1/survivors/:id/inventory" do
    context "when inventory does not exist yet" do
      before do
        patch api_v1_survivor_inventory_path(survivor.id),
              params: {
                inventory: {
                  kind: inventory_kind,
                  operation: "add",
                  quantity: 10
                }
              }.to_json,
              headers: headers
      end

      it "updates inventory and adds quantity" do
        expect(response).to have_http_status(:ok)
      end

      it "adds quantity to existing inventory" do
        json = JSON.parse(response.body)
        expect(json["inventory"][inventory_kind]).to eq(10)
      end
    end

    context "when removing quantity in Inventory" do
      before do
        patch api_v1_survivor_inventory_path(survivor.id),
              params: {
                inventory: {
                  kind: inventory_kind,
                  operation: "add",
                  quantity: 5
                }
              }.to_json,
              headers: headers
      end

      context "when removing more than available" do
        before do
          patch api_v1_survivor_inventory_path(survivor.id),
                params: {
                  inventory: {
                    kind: inventory_kind,
                    operation: "remove",
                    quantity: 10
                  }
                }.to_json,
                headers: headers
        end

        it "returns 422 with error message" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error message" do
          json = JSON.parse(response.body)
          expect(json["error"]).to match(/Cannot remove more than available/)
        end
      end

      context "when removing less than available" do
        before do
          patch api_v1_survivor_inventory_path(survivor.id),
                params: {
                  inventory: {
                    kind: inventory_kind,
                    operation: "remove",
                    quantity: 3
                  }
                }.to_json,
                headers: headers
        end

        it "removes quantity from existing inventory" do
          expect(response).to have_http_status(:ok)
        end

        it "removes quantity from existing inventory" do
          json = JSON.parse(response.body)
          expect(json["inventory"][inventory_kind]).to eq(2)
        end
      end
    end
  end
end
