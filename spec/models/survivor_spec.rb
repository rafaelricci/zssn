require 'rails_helper'

RSpec.describe Survivor, type: :model do
  describe 'validations' do
    context 'when all attributes are valid' do
      it 'is valid' do
        survivor = build(:survivor)
        expect(survivor).to be_valid
      end
    end

    context 'when name is missing' do
      let(:survivor) { build(:survivor, name: nil) }

      it 'is invalid' do
        expect(survivor).to be_invalid
      end

      it 'adds error on name' do
        survivor.valid?
        expect(survivor.errors[:name]).to include("can't be blank")
      end
    end

    context 'when age is missing' do
      let(:survivor) { build(:survivor, age: nil) }

      it 'is invalid' do
        expect(survivor).to be_invalid
      end

      it 'adds error on age' do
        survivor.valid?
        expect(survivor.errors[:age]).to include("can't be blank")
      end
    end

    context 'when gender is missing' do
      let(:survivor) { build(:survivor, gender: nil) }

      it 'is invalid' do
        expect(survivor).to be_invalid
      end

      it 'adds error on gender' do
        survivor.valid?
        expect(survivor.errors[:gender]).to include("can't be blank")
      end
    end

    context 'when latitude is missing' do
      let(:survivor) { build(:survivor, lat: nil) }

      it 'is invalid' do
        expect(survivor).to be_invalid
      end

      it 'adds error on lat' do
        survivor.valid?
        expect(survivor.errors[:lat]).to include("can't be blank")
      end
    end

    context 'when longitude is missing' do
      let(:survivor) { build(:survivor, lon: nil) }

      it 'is invalid' do
        expect(survivor).to be_invalid
      end

      it 'adds error on lon' do
        survivor.valid?
        expect(survivor.errors[:lon]).to include("can't be blank")
      end
    end

    context 'when updating an infected survivor' do
      let(:survivor) { create(:survivor) }
      before do
        create_list(:infection_report, 3, reported: survivor)
      end

      it 'is invalid' do
        survivor.update(name: 'New Name')
        expect(survivor).to be_invalid
      end

      it 'adds error on base' do
        survivor.update(name: 'New Name')
        expect(survivor.errors[:base]).to include("Infected survivor cannot be modified.")
      end
    end
  end

  describe 'enums' do
    it 'defines gender enum with correct values' do
      expect(Survivor.genders.keys).to contain_exactly('male', 'female', 'other')
    end
  end

  describe 'callbacks' do
    context 'when lat and lon are present' do
      let(:lat) { Faker::Address.latitude }
      let(:lon) { Faker::Address.longitude }
      let(:survivor) { build(:survivor, lat: lat, lon: lon) }

      before { survivor.valid? }

      it 'sets last_location as a Point' do
        expect(survivor.last_location).to be_a(RGeo::Feature::Point)
      end

      it 'sets last_location.x as lon' do
        expect(survivor.last_location.x).to eq lon
      end

      it 'sets last_location.y as lat' do
        expect(survivor.last_location.y).to eq lat
      end
    end

    context 'when lat is nil' do
      it 'does not set last_location' do
        survivor = build(:survivor, lat: nil, lon: 20.0)
        survivor.valid?
        expect(survivor.last_location).to be_nil
      end
    end

    context 'when lon is nil' do
      it 'does not set last_location' do
        survivor = build(:survivor, lat: 10.0, lon: nil)
        survivor.valid?
        expect(survivor.last_location).to be_nil
      end
    end

    context 'when lat and lon are nil' do
      it 'does not set last_location' do
        survivor = build(:survivor, lat: nil, lon: nil)
        survivor.valid?
        expect(survivor.last_location).to be_nil
      end
    end

    context 'after create' do
      let(:survivor) { create(:survivor) }

      it 'initializes inventory' do
        expect(survivor.inventories.count).to eq Inventory.kinds.keys.size
      end

      it 'sets inventory quantity to 0' do
        survivor.inventories.each do |inventory|
          expect(inventory.quantity).to eq 0
        end
      end
    end
  end

  describe '#inventory_itens' do
    let(:survivor) { create(:survivor) }

    it 'returns a hash of inventory items with their quantities' do
      expected_result = {
        food: 0,
        water: 0,
        medicine: 0,
        ammo: 0
      }
      expect(survivor.inventory_itens).to eq expected_result
    end
  end

  describe '#infected?' do
    let(:survivor) { create(:survivor) }

    context 'when survivor has 3 or more infection reports' do
      before do
        create_list(:infection_report, 3, reported: survivor)
      end

      it 'returns true' do
        expect(survivor.infected?).to be true
      end
    end

    context 'when survivor has less than 3 infection reports' do
      before do
        create_list(:infection_report, 2, reported: survivor)
      end

      it 'returns false' do
        expect(survivor.infected?).to be false
      end
    end
  end
end
