require 'rails_helper'

RSpec.describe Trade::PerformService, type: :service do
  let(:from) { create(:survivor) }
  let(:to)   { create(:survivor) }

  before do
    from.inventories.find_by(kind: :water).update!(quantity: 2)
    to.inventories.find_by(kind: :medicine).update!(quantity: 4)
  end

  describe ".call" do
    context "when trade is valid" do
      it "executes successfully and updates inventories" do
        expect {
          described_class.call(
            from_id: from.id,
            to_id: to.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          )
        }.to change {
          [
            from.inventories.find_by(kind: :medicine).quantity,
            to.inventories.find_by(kind: :water).quantity
          ]
        }.from([0, 0]).to([4, 2])
      end
    end

    context "when trade is unbalanced" do
      it "raises a balanced trade error" do
        expect {
          described_class.call(
            from_id: from.id,
            to_id: to.id,
            offer: { water: 1 },
            request: { medicine: 3 }
          )
        }.to raise_error(RuntimeError, "Trade must be balanced (equal points on both sides)")
      end
    end

    context "when a survivor is infected" do
      before { create_list(:infection_report, 3, reported: from) }

      it "raises an infection error" do
        expect {
          described_class.call(
            from_id: from.id,
            to_id: to.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          )
        }.to raise_error(RuntimeError, "Survivor is infected")
      end
    end

    context "when trading with self" do
      it "raises a self-trade error" do
        expect {
          described_class.call(
            from_id: from.id,
            to_id: from.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          )
        }.to raise_error(RuntimeError, "Survivor cannot trade with themselves")
      end
    end

    context "when survivor does not have enough items" do
      before { from.inventories.find_by(kind: :water).update!(quantity: 1) }

      it "raises an inventory quantity error" do
        expect {
          described_class.call(
            from_id: from.id,
            to_id: to.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          )
        }.to raise_error(RuntimeError, "Survivor #{from.id} does not have enough water")
      end
    end

    context "when inventory kind is missing" do
      before { from.inventories.find_by(kind: :water).destroy! }

      it "raises a missing item error" do
        expect {
          described_class.call(
            from_id: from.id,
            to_id: to.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          )
        }.to raise_error(RuntimeError, "Survivor #{from.id} does not have item water")
      end
    end

    context "when from survivor is not found" do
      it "raises a not found error for from_id" do
        expect {
          described_class.call(
            from_id: -1,
            to_id: to.id,
            offer: { water: 2 },
            request: { medicine: 4 }
          )
        }.to raise_error(RuntimeError, "Survivor not found: -1")
      end
    end

    context "when to survivor is not found" do
      it "raises a not found error for to_id" do
        expect {
          described_class.call(
            from_id: from.id,
            to_id: -999,
            offer: { water: 2 },
            request: { medicine: 4 }
          )
        }.to raise_error(RuntimeError, "Survivor not found: -999")
      end
    end

    context "when item kind is invalid" do
      it "raises an error on point value lookup" do
        expect {
          described_class.call(
            from_id: from.id,
            to_id: to.id,
            offer: { chocolate: 1 },
            request: { medicine: 2 }
          )
        }.to raise_error(RuntimeError, "Invalid item kind: chocolate")
      end
    end
  end
end
