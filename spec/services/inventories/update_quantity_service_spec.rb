RSpec.describe Inventories::UpdateQuantityService do
  let(:survivor) { create(:survivor) }
  let(:kind) { :food }

  before do
    survivor.inventories.find_by(kind: kind).update!(quantity: 5)
  end

  describe '.call' do
    it 'adds quantity to existing inventory' do
      result = described_class.call(
        survivor_id: survivor.id,
        kind: kind,
        operation: 'add',
        quantity: 3
      )
      expect(result.quantity).to eq(8)
    end

    it 'removes quantity from existing inventory' do
      result = described_class.call(
        survivor_id: survivor.id,
        kind: kind,
        operation: 'remove',
        quantity: 2
      )
      expect(result.quantity).to eq(3)
    end

    context 'when removing more than available' do
      it 'raises an error' do
        expect {
          described_class.call(
            survivor_id: survivor.id,
            kind: kind,
            operation: 'remove',
            quantity: 10
          )
        }.to raise_error(RuntimeError, 'Cannot remove more than available')
      end
    end

    context 'when invalid operation is provided' do
      it 'raises an error' do
        expect {
          described_class.call(
            survivor_id: survivor.id,
            kind: kind,
            operation: 'invalid_operation',
            quantity: 2
          )
        }.to raise_error(RuntimeError, 'Invalid operation: invalid_operation')
      end
    end

    context 'when survivor not found' do
      it 'raises an error for survivor not found' do
        expect {
          described_class.call(
            survivor_id: -1,
            kind: kind,
            operation: 'add',
            quantity: 2
          )
        }.to raise_error(RuntimeError, 'Survivor not found: -1')
      end
    end

    context 'when inventory item not found' do
      it 'raises an error for inventory item not found' do
        expect {
          described_class.call(
            survivor_id: survivor.id,
            kind: :invalid_kind,
            operation: 'add',
            quantity: 2
          )
        }.to raise_error(RuntimeError, 'Inventory item not found: invalid_kind')
      end
    end

    context 'when survivor is infected' do
      before do
        create_list(:infection_report, 3, reported: survivor)
      end

      it 'raises an error' do
        expect {
          described_class.call(
            survivor_id: survivor.id,
            kind: kind,
            operation: 'remove',
            quantity: 2
          )
        }.to raise_error(RuntimeError, 'Survivor is infected')
      end
    end
  end
end
