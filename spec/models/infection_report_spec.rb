require 'rails_helper'

RSpec.describe InfectionReport, type: :model do
  describe 'validations' do
    context 'when all attributes are valid' do
      it 'is valid' do
        infection_report = create(:infection_report)
        expect(infection_report).to be_valid
      end
    end

    context 'when reporter is missing' do
      let(:infection_report) { build(:infection_report, reporter: nil) }

      it 'is invalid' do
        expect(infection_report).to be_invalid
      end

      it 'adds error on reporter' do
        infection_report.valid?
        expect(infection_report.errors[:reporter]).to include("must exist")
      end
    end

    context 'when reported is missing' do
      let(:infection_report) { build(:infection_report, reported: nil) }

      it 'is invalid' do
        expect(infection_report).to be_invalid
      end

      it 'adds error on reported' do
        infection_report.valid?
        expect(infection_report.errors[:reported]).to include("must exist")
      end
    end

    context 'when reporter and reported are the same' do
      let(:survivor) { create(:survivor) }
      let(:infection_report) { build(:infection_report, reporter: survivor, reported: survivor) }

      it 'is invalid' do
        expect(infection_report).to be_invalid
      end

      it 'adds error on reporter_id' do
        infection_report.valid?
        expect(infection_report.errors[:reporter_id]).to include("Cannot report to itself")
      end
    end

    context 'when reporter has already reported the same survivor' do
      let(:reporter) { create(:survivor) }
      let(:reported) { create(:survivor) }
      let!(:existing_report) { create(:infection_report, reporter: reporter, reported: reported) }
      let(:new_report) { build(:infection_report, reporter: reporter, reported: reported) }

      it 'is invalid' do
        expect(new_report).to be_invalid
      end

      it 'adds error on reporter_id' do
        new_report.valid?
        expect(new_report.errors[:reporter_id]).to include("Already reported this survivor")
      end
    end
  end

  describe '#reports_from_reported_count' do
    let(:reporter) { create(:survivor) }
    let(:reported) { create(:survivor) }
    let!(:report1) { create(:infection_report, reporter: reporter, reported: reported) }
    let!(:report2) { create(:infection_report, reporter: create(:survivor), reported: reported) }

    it 'returns the count of distinct reports from the reported survivor' do
      expect(report1.reports_from_reported_count).to eq(2)
    end
  end
end
