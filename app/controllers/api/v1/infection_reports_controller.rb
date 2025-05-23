class Api::V1::InfectionReportsController < ApplicationController
  def create
    @report = InfectionReport.new(report_params)

    if @report.save
      render :create, status: :created
    else
      render json: { errors: @report.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def report_params
    params.require(:infection_report).permit(:reporter_id, :reported_id)
  end
end
