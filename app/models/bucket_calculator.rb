Bucket = Struct.new :name, :bucket_size, :content
class BucketCalculator
  def initialize(bucket1_size, bucket2_size, desired_amount)
    params = [
      bucket1_size, bucket2_size, desired_amount
    ]
    unless params.all? do |p|
             p.is_a? Integer
           end && params.all?(&:positive?)
      raise BucketCalculatorException,
            'Invalid parameters bucket1_size, bucket2_size, desired_amount must be positive integers'
    end

    @bucket1_size = bucket1_size
    @bucket2_size = bucket2_size
    @desired_amount = desired_amount
    raise BucketCalculatorException, 'Impossible to calculate with the provided params' unless check_params
  end

  def check_params
    greater_common_divisor = @bucket1_size.gcd(@bucket2_size)
    desired_divisible_by_greater_common_divisor = (@desired_amount % greater_common_divisor).zero?
    bigger_than_buckets = @desired_amount > @bucket1_size && @desired_amount > @bucket2_size

    return false if bigger_than_buckets || !desired_divisible_by_greater_common_divisor

    true
  end

  def init_buckets
    [Bucket.new('bucket1', @bucket1_size, 0), Bucket.new('bucket2', @bucket2_size, 0)]
  end

  def calculate_steps
    steps_list = if @desired_amount > @bucket1_size && @desired_amount < @bucket2_size
                   bucket1, bucket2 = init_buckets
                   steps1 = roll_down(bucket2, bucket1)
                   bucket1, bucket2 = init_buckets
                   steps2 = roll_up(bucket2, bucket1)
                   [steps1, steps2]
                 elsif @desired_amount < @bucket1_size && @desired_amount > @bucket2_size
                   bucket1, bucket2 = init_buckets
                   steps1 = roll_down(bucket1, bucket2)
                   bucket1, bucket2 = init_buckets
                   steps2 = roll_up(bucket1, bucket2)
                   [steps1, steps2]
                 elsif @desired_amount == @bucket1_size
                   bucket1 = init_buckets.first
                   [[fill_bucket(bucket1)]]
                 elsif @desired_amount == @bucket2_size
                   bucket2 = init_buckets.last
                   [[fill_bucket(bucket2)]]
                 end
    steps = steps_list.reject(&:empty?).min_by(&:size)
    raise BucketCalculatorException, 'Impossible to calculate with the provided params' unless steps&.any?

    steps
  end

  def roll_down(bucket1, bucket2)
    steps = []
    steps << fill_bucket(bucket1) if bucket1.content.zero?
    while bucket1.content > @desired_amount
      steps << empty_bucket(bucket2)
      steps << transfer_from_to(bucket1, bucket2)
    end
    return steps.compact if bucket1.content == @desired_amount

    []
  end

  def roll_up(bucket1, bucket2)
    steps = []
    while bucket1.content < @desired_amount && bucket1.bucket_size > @desired_amount
      steps << fill_bucket(bucket2)
      steps << transfer_from_to(bucket2, bucket1)
    end
    return steps.compact if bucket1.content == @desired_amount

    []
  end

  def fill_bucket(bucket)
    return if bucket.content == bucket.bucket_size

    bucket.content = bucket.bucket_size
    { step: :fill, bucket: bucket.name, "#{bucket.name}_content" => bucket.content }
  end

  def transfer_from_to(bucket1, bucket2)
    return unless bucket1.content.positive? && bucket2.content < bucket2.bucket_size

    transfer_amount = bucket2.bucket_size - bucket2.content
    transfer_amount = bucket1.content if bucket1.content < transfer_amount
    bucket1.content -= transfer_amount
    bucket2.content += transfer_amount
    { step: :transfer, from: bucket1.name, to: bucket2.name, transfer_amount:,
      "#{bucket2.name}_content" => bucket2.content, "#{bucket1.name}_content" => bucket1.content }
  end

  def empty_bucket(bucket)
    return unless bucket.content != 0

    bucket.content = 0
    { step: :empty, bucket: bucket.name, bucket_content: 0 }
  end
end
