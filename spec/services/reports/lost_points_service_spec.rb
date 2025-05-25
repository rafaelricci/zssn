require "rails_helper"

RSpec.describe Reports::LostPointsService do
  let(:result) { described_class.call }

  describe ".call" do
    context "when there are no infected survivors" do
      before { create(:survivor, infected: false) }

      it "returns a success result" do
        expect(result).to be_success
      end

      it "returns 0 lost points" do
        expect(result.data[:lost_points]).to eq(0)
      end
    end

    context "when there are infected survivors with items" do
      before do
        infected = create(:survivor)
        infected.inventories.find_by(kind: "water").update!(quantity: 1)
        infected.inventories.find_by(kind: "medicine").update!(quantity: 2)
        create_list(:infection_report, 3, reported: infected)
      end

      it "returns a success result" do
        expect(result).to be_success
      end

      it "returns correct total of lost points" do
        expect(result.data[:lost_points]).to eq(8)
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
