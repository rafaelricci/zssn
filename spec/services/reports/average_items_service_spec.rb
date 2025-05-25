require "rails_helper"

RSpec.describe Reports::AverageItemsService do
  let(:result) { described_class.call }

  describe ".call" do
    context "when there are non-infected survivors with inventories" do
      before do
        survivor1 = create(:survivor, infected: false)
        survivor2 = create(:survivor, infected: false)

        survivor1.inventories.find_by(kind: "water").update!(quantity: 4)
        survivor2.inventories.find_by(kind: "water").update!(quantity: 2)
      end

      it "returns a success result" do
        expect(result).to be_success
      end

      it "returns correct average for water" do
        expect(result.data[:averages]["water"]).to eq(3.0)
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(Survivor).to receive(:where).and_raise(StandardError, "unexpected failure")
      end

      it "returns a failure result" do
        expect(result).to be_failure
      end

      it "returns the error message" do
        expect(result.error).to eq("unexpected failure")
      end
    end
  end
end
