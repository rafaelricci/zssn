require 'rails_helper'

RSpec.describe Inventory, type: :model do
  describe 'validations' do
    context 'when all attributes are valid' do
      it 'is valid' do
        inventory = build(:inventory)
        expect(inventory).to be_valid
      end
    end

    context 'when quantity is missing' do
      let(:inventory) { build(:inventory, quantity: nil) }

      it 'is invalid' do
        expect(inventory).to be_invalid
      end

      it 'adds error on quantity' do
        inventory.valid?
        expect(inventory.errors[:quantity]).to include("is not a number")
      end
    end

    context 'when kind is missing' do
      let(:inventory) { build(:inventory, kind: nil) }

      it 'is invalid' do
        expect(inventory).to be_invalid
      end

      it 'adds error on kind' do
        inventory.valid?
        expect(inventory.errors[:kind]).to include("can't be blank")
      end
    end

    context 'when survivor is missing' do
      let(:inventory) { build(:inventory, survivor: nil) }

      it 'is invalid' do
        expect(inventory).to be_invalid
      end

      it 'adds error on survivor' do
        inventory.valid?
        expect(inventory.errors[:survivor]).to include("must exist")
      end
    end
  end

  describe 'enums' do
    it 'defines kind enum with correct values' do
      expect(Inventory.kinds.keys).to contain_exactly('water', 'food', 'medicine', 'ammo')
    end
  end
end
