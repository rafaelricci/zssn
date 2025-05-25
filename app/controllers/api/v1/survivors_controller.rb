class Api::V1::SurvivorsController < ApplicationController
  before_action :set_survivor, only: [ :update ]

  def create
    @survivor = Survivor.new(survivor_params)

    if @survivor.save
      render :create, status: :created
    else
      render json: { errors: @survivor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @survivor.update(location_params)
      render :update
    else
      render json: { errors: @survivor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_survivor
    @survivor = Survivor.find(params[:id])
  end

  def survivor_params
    params.require(:survivor).permit(:name, :age, :gender, :latitude, :longitude)
  end

  def location_params
    params.require(:survivor).permit(:latitude, :longitude)
  end
end
