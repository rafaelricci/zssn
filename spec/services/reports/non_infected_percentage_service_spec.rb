require "rails_helper"

RSpec.describe Reports::NonInfectedPercentageService do
  let(:result) { described_class.call }

  describe ".call" do
    context "when there are no survivors" do
      it "returns a success result" do
        expect(result).to be_success
      end

      it "returns 0.0 as percentage" do
        expect(result.data[:percentage]).to eq(0.0)
      end
    end

    context "when there are infected and non-infected survivors" do
      before do
        infected = create(:survivor)
        create_list(:infection_report, 3, reported: infected)
      end

      it "returns a success result" do
        expect(result).to be_success
      end

      it "calculates the correct non-infected percentage" do
        expect(result.data[:percentage]).to eq(75.0)
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(Survivor).to receive(:count).and_raise(StandardError, "unexpected failure")
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
