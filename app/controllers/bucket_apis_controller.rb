class BucketApisController < ApplicationController
  def create
    bucket_x = params[:x_capacity]
    bucket_y = params[:y_capacity]
    desired_amount = params[:z_amount_wanted]
    calculator = BucketCalculator.new(bucket_x, bucket_y, desired_amount)
    steps = calculator.calculate_steps
    steps.last[:status] = :solved
    render json: { solution: steps }
  rescue BucketCalculatorException => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
