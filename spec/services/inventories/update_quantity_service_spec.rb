RSpec.describe Inventories::UpdateQuantityService do
  let(:survivor) { create(:survivor) }
  let(:kind) { :food }

  before do
    survivor.inventories.find_by(kind: kind).update!(quantity: 5)
  end

  describe '.call' do
    context 'when operation is add' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: kind,
          operation: 'add',
          quantity: 3
        )
      end

      it 'returns success result' do
        expect(result.success?).to be true
      end

      it 'adds quantity to existing inventory' do
        expect(result.data.quantity).to eq(8)
      end
    end

    context 'when operation is remove' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: kind,
          operation: 'remove',
          quantity: 2
        )
      end

      it 'returns success result' do
        expect(result.success?).to be true
      end

      it 'removes quantity from existing inventory' do
        expect(result.data.quantity).to eq(3)
      end
    end

    context 'when removing more than available' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: kind,
          operation: 'remove',
          quantity: 10
        )
      end
      it 'returns failure result' do
        expect(result.failure?).to be true
      end

      it 'returns failure message' do
        expect(result.error).to eq('Cannot remove more than available')
      end
    end

    context 'when invalid operation is provided' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: kind,
          operation: 'invalid_operation',
          quantity: 2
        )
      end

      it 'returns failure result' do
        expect(result.failure?).to be true
      end

      it 'returns failure result with message' do
        expect(result.error).to eq('Invalid operation')
      end
    end

    context 'when survivor not found' do
      let(:result) do
        described_class.call(
          survivor_id: -1,
          kind: kind,
          operation: 'add',
          quantity: 2
        )
      end

      it 'returns failure result' do
        expect(result.failure?).to be true
      end

      it 'returns failure result with message' do
        expect(result.error).to eq('Survivor not found: -1')
      end
    end

    context 'when inventory item not found' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: :invalid_kind,
          operation: 'add',
          quantity: 2
        )
      end

      it 'returns failure result' do
        expect(result.failure?).to be true
      end

      it 'returns failure result with message' do
        expect(result.error).to eq('Inventory item not found: invalid_kind')
      end
    end

    context 'when survivor is infected' do
      let(:result) do
        described_class.call(
          survivor_id: survivor.id,
          kind: kind,
          operation: 'remove',
          quantity: 2
        )
      end

      before do
        create_list(:infection_report, 3, reported: survivor)
      end

      it 'returns failure result' do
        expect(result.failure?).to be true
      end

      it 'returns failure result with message' do
        expect(result.error).to eq('Survivor is infected')
      end
    end
  end
end
