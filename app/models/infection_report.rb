class InfectionReport < ApplicationRecord
  belongs_to :reporter, class_name: "Survivor"
  belongs_to :reported, class_name: "Survivor"

  validates :reporter_id, uniqueness: { scope: :reported_id, message: "Already reported this survivor" }
  validate :cannot_report_self

  def reports_from_reported_count
    reported.infection_reports.distinct.count
  end

  private

  def cannot_report_self
    errors.add(:reporter_id, "Cannot report to itself") if reporter_id == reported_id
  end
end
