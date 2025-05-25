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
      let(:report) { build(:infection_report, reporter: survivor, reported: survivor)}

      it 'is invalid' do
        expect(report).not_to be_valid
      end

      it 'adds error on reporter_id' do
        report.validate

        expect(report.errors[:reporter_id]).to include("Cannot report to itself")
      end
    end
  end

  # describe 'infection trigger' do
  #   let(:reported) { create(:survivor) }

  #   context 'with less than 3 unique reporters' do
  #     before do
  #       create_list(:survivor, 2).each do |reporter|
  #         create(:infection_report, reporter: reporter, reported: reported)
  #       end
  #     end

  #     it 'does not infect the survivor' do
  #       reported.reload

  #       expect(reported.infected?).to be_falsey
  #     end
  #   end

  #   context 'with 3 or more unique reporters' do
  #     before do
  #       create_list(:infection_report, 3, reported: reported)
  #     end

  #     it 'infects the survivor' do
  #       reported.reload
        
  #       expect(reported.infected?).to be_truthy
  #     end
  #   end

  #   context 'when survivor is already infected' do
  #     before do
  #       create_list(:infection_report, 3, reported: reported)
  #     end

  #     it 'does not re-infect or change status' do
  #       expect {
  #         create(:infection_report, reporter: create(:survivor), reported: reported)
  #       }.not_to change { reported.reload.infected? }.from(true)
  #     end
  #   end
  # end
end
