require 'rails_helper'

RSpec.describe Inventory, type: :model do
  describe 'validations for inventory attributes' do
    it 'is valid when all required attributes are present and correct' do
      inventory = build(:inventory)
      expect(inventory).to be_valid
    end

    it 'is invalid without a kind value' do
      inventory = build(:inventory, kind: nil)
      expect(inventory).not_to be_valid
    end

    it 'is invalid without a quantity value' do
      inventory = build(:inventory, quantity: nil)
      expect(inventory).not_to be_valid
    end

    it 'is invalid when quantity is negative' do
      inventory = build(:inventory, quantity: -1)
      expect(inventory).not_to be_valid
    end
  end

  context 'when the survivor is infected' do
    let(:survivor) { create(:survivor) }
    let(:inventory) { survivor.inventories.first }

    before do
      create_list(:infection_report, 3, reported: survivor)
      survivor.reload
    end

    it 'is invalid when trying to update inventory' do
      inventory.quantity = 10
      
      expect(inventory).to be_invalid
    end

    it 'raises an error when trying to persist changes to inventory' do
      inventory.quantity = 10
      expect { inventory.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'adds an appropriate error message to base' do
      inventory.quantity = 10
      inventory.save
      expect(inventory.errors[:base]).to include("Survivor is infected and cannot modify inventory.")
    end
  end

  describe 'enum definitions' do
    it 'defines kind enum with the correct item types' do
      expect(Inventory.kinds.keys).to contain_exactly('water', 'food', 'medicine', 'ammo')
    end
  end
end
