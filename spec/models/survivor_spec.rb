require 'rails_helper'

RSpec.describe Survivor, type: :model do
  describe 'validations on survivor attributes' do
    it 'is valid with all required fields filled correctly' do
      survivor = build(:survivor)
      expect(survivor).to be_valid
    end

    it 'is invalid without a name' do
      survivor = build(:survivor, name: nil)
      expect(survivor).not_to be_valid
    end

    it 'is invalid without an age' do
      survivor = build(:survivor, age: nil)
      expect(survivor).not_to be_valid
    end

    it 'is invalid without a latitude' do
      survivor = build(:survivor, latitude: nil)
      expect(survivor).not_to be_valid
    end

    it 'is invalid without a longitude' do
      survivor = build(:survivor, longitude: nil)
      expect(survivor).not_to be_valid
    end

    it 'is invalid when latitude is out of allowed range' do
      survivor = build(:survivor, latitude: 100)
      expect(survivor).not_to be_valid
    end

    it 'is invalid when longitude is out of allowed range' do
      survivor = build(:survivor, longitude: -200)
      expect(survivor).not_to be_valid
    end

    context 'restrictions for infected survivors' do
      let(:survivor) { create(:survivor) }

      context 'when the survivor is not infected' do
        before do
          create_list(:infection_report, 2, reported: survivor)
        end

        it 'can be updated normally' do
          survivor.name = Faker::Name.name
          expect(survivor.save).to be_truthy
        end

        context 'when trying to set infected = true with less than 3 reports' do
          before do
            survivor.infected = true
            survivor.save
          end

          it 'prevents setting infected to true' do
            expect(survivor.errors[:base]).to include("Survivor must have at least 3 distinct infection reports to be infected")
          end

          it 'does not persist the infected status' do
            expect(survivor.reload.infected).to be_falsey
          end
        end
      end

      context 'when the survivor is already infected' do
        let(:survivor) { create(:survivor) }

        before do
          create_list(:infection_report, 3, reported: survivor)
          survivor.reload
        end

        it 'prevents updating any attribute' do
          survivor.name = Faker::Name.name
          expect(survivor.save).to be_falsey
        end

        it 'does not persist the updated attributes' do
          original_name = survivor.name
          survivor.name = "Mutated #{original_name}"
          survivor.save
          expect(survivor.reload.name).to eq(original_name)
        end

        it 'adds the correct error message to base' do
          survivor.name = Faker::Name.name
          survivor.save
          expect(survivor.errors[:base]).to include("Infected survivor cannot be updated")
        end
      end
    end
  end

  describe 'inventory creation after survivor is created' do
    let(:survivor) { create(:survivor) }

    it 'automatically creates 4 inventory records' do
      expect(survivor.inventories.size).to eq(4)
    end

    it 'sets all inventory quantities to 0' do
      quantities = survivor.inventories.map(&:quantity).uniq
      expect(quantities).to eq([ 0 ])
    end
  end
end
