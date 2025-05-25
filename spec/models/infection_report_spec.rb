require 'rails_helper'

RSpec.describe InfectionReport, type: :model do
  describe 'validations' do
    it 'is valid with unique reporter and reported' do
      report = build(:infection_report)

      expect(report).to be_valid
    end

    context 'when reporter reports the same survivor twice' do
      let(:survivor) { create(:survivor) }
      let(:reporter) { create(:survivor) }
      let(:duplicate) { build(:infection_report, reporter: reporter, reported: survivor) }

      before do
        create(:infection_report, reporter: reporter, reported: survivor)
      end

      it 'is invalid' do
        expect(duplicate).not_to be_valid
      end

      it 'adds error on reporter_id' do
        duplicate.validate

        expect(duplicate.errors[:reporter_id]).to include("Already reported this survivor")
      end
    end

    context 'when reporter tries to report themselves' do
      let(:survivor) { create(:survivor) }
      let(:report) { build(:infection_report, reporter: survivor, reported: survivor) }

      it 'is invalid' do
        expect(report).not_to be_valid
      end

      it 'adds error on reporter_id' do
        report.validate

        expect(report.errors[:reporter_id]).to include("Cannot report to itself")
      end
    end
  end
end
