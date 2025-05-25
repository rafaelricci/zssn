require 'rails_helper'

RSpec.describe Inventories::UpdateQuantityService, type: :service do
  describe '#call' do
    let(:survivor) { create(:survivor) }
    let(:inventory) { survivor.inventories.find_by(kind: :water) }

    context 'when operation is :add' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: :water,
          operation: :add,
          quantity: 3
        )
      end

      it 'returns success result' do
        expect(result).to be_success
      end

      it 'increments inventory quantity' do
        expect(result.data.quantity).to eq(3)
      end
    end

    context 'when operation is :remove' do
      before { inventory.update!(quantity: 5) }

      context 'with sufficient quantity' do
        let(:result) do
          described_class.call(
            survivor_id: survivor.id,
            kind: :water,
            operation: :remove,
            quantity: 2
          )
        end

        it 'returns success result' do
          expect(result).to be_success
        end

        it 'decrements inventory quantity' do
          expect(result.data.quantity).to eq(3)
        end
      end

      context 'with insufficient quantity' do
        let(:result) do
          described_class.call(
            survivor_id: survivor.id,
            kind: :water,
            operation: :remove,
            quantity: 10
          )
        end

        it 'returns failure result' do
          expect(result).to be_failure
        end

        it 'has error message about insufficient quantity' do
          expect(result.error).to eq("Cannot remove more than available")
        end
      end
    end

    context 'when survivor is infected' do
      before do
        create_list(:infection_report, 3, reported: survivor)
      end

      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: :water,
          operation: :add,
          quantity: 1
        )
      end

      it 'returns failure result' do
        expect(result).to be_failure
      end

      it 'has error message about infection' do
        expect(result.error).to eq("Survivor is infected")
      end
    end

    context 'when operation is invalid' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: :water,
          operation: :transfer,
          quantity: 1
        )
      end

      it 'returns failure result' do
        expect(result).to be_failure
      end

      it 'has error message about invalid operation' do
        expect(result.error).to eq("Invalid operation: transfer")
      end
    end

    context 'when survivor does not exist' do
      let(:result) do
        described_class.call(
          survivor_id: 999_999,
          kind: :water,
          operation: :add,
          quantity: 1
        )
      end

      it 'returns failure result' do
        expect(result).to be_failure
      end

      it 'has error message about survivor not found' do
        expect(result.error).to eq("Survivor not found: 999999")
      end
    end

    context 'when inventory item does not exist' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: :invalid_item,
          operation: :add,
          quantity: 1
        )
      end

      it 'returns failure result' do
        expect(result).to be_failure
      end

      it 'has error message about inventory not found' do
        expect(result.error).to eq("Inventory item not found: invalid_item")
      end
    end
  end
end
