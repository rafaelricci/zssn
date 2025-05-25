class InfectionReport < ApplicationRecord
  belongs_to :reporter, class_name: "Survivor"
  belongs_to :reported, class_name: "Survivor"

  validates :reporter_id, uniqueness: { scope: :reported_id, message: "Already reported this survivor" }
  validate :cannot_report_self

  after_create :mark_reported_as_infected

  private

  def cannot_report_self
    if reporter_id == reported_id
      errors.add(:reporter_id, "Cannot report to itself")
      throw :abort
    end
  end

  def mark_reported_as_infected
    return if reported.infected?

    distinct_reports = InfectionReport.where(reported: reported).distinct.count(:reporter_id)

    if distinct_reports >= 3
      reported.update!(infected: true)
    end
  end
end
