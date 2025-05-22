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
  end
end
