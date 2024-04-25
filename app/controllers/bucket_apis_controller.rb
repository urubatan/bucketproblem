class BucketApisController < ApplicationController
  def create
    bucket_x = params[:x_capacity]
    bucket_y = params[:y_capacity]
    desired_amount = params[:z_amount_wanted]
    render_options = Rails.cache.fetch(cache_key(bucket_x, bucket_y, desired_amount)) do
      calculator = BucketCalculator.new(bucket_x, bucket_y, desired_amount)
      steps = calculator.calculate_steps
      steps.last[:status] = :solved
      { json: { solution: steps } }
    rescue BucketCalculatorException => e
      { json: { error: e.message }, status: :unprocessable_entity }
    end
    render render_options
  end

  private
  def cache_key(param1, param2, param3)
    "bucketcalc#{{ param1:, param2:, param3: }.to_json}"
  end
end
