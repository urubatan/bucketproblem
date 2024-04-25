require 'test_helper'

class BucketCalculatorTest < ActiveSupport::TestCase
  test 'non integer params' do
    assert_raise BucketCalculatorException do
      BucketCalculator.new(1, 2, 'a')
    end
  end

  test 'down' do
    calculator = BucketCalculator.new(9, 2, 5)
    steps = calculator.calculate_steps
    assert steps.count > 1
    assert_equal steps,
                 [{ :step => :fill, :bucket => 'bucketx', 'bucketx_content' => 9 },
                  { :step => :transfer, :from => 'bucketx', :to => 'buckety', :transfer_amount => 2,
                    'buckety_content' => 2, 'bucketx_content' => 7 },
                  { step: :empty, bucket: 'buckety', bucket_content: 0 },
                  { :step => :transfer, :from => 'bucketx', :to => 'buckety', :transfer_amount => 2,
                    'buckety_content' => 2, 'bucketx_content' => 5 }]
  end
  test 'up' do
    calculator = BucketCalculator.new(1, 8, 5)
    steps = calculator.calculate_steps
    assert steps.count > 1
    assert_equal steps,
                 [{ :step => :fill, :bucket => 'buckety', 'buckety_content' => 8 },
                  { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 1,
                    'bucketx_content' => 1, 'buckety_content' => 7 },
                  { step: :empty, bucket: 'bucketx', bucket_content: 0 },
                  { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 1,
                    'bucketx_content' => 1, 'buckety_content' => 6 },
                  { step: :empty, bucket: 'bucketx', bucket_content: 0 },
                  { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 1,
                    'bucketx_content' => 1, 'buckety_content' => 5 }]
  end

  test 'first from spec' do
    calculator = BucketCalculator.new(2, 10, 4)
    steps = calculator.calculate_steps
    assert steps.count > 1
    assert_equal steps, [{ :step => :fill, :bucket => 'bucketx', 'bucketx_content' => 2 },
                         { :step => :transfer, :from => 'bucketx', :to => 'buckety', :transfer_amount => 2,
                           'buckety_content' => 2, 'bucketx_content' => 0 },
                         { :step => :fill, :bucket => 'bucketx', 'bucketx_content' => 2 },
                         { :step => :transfer, :from => 'bucketx', :to => 'buckety', :transfer_amount => 2,
                           'buckety_content' => 4, 'bucketx_content' => 0 }]
  end
  test 'second from spec' do
    calculator = BucketCalculator.new(2, 100, 96)
    steps = calculator.calculate_steps
    assert steps.count > 1
    assert_equal steps, [{ :step => :fill, :bucket => 'buckety', 'buckety_content' => 100 },
                         { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 2,
                           'bucketx_content' => 2, 'buckety_content' => 98 },
                         { step: :empty, bucket: 'bucketx', bucket_content: 0 },
                         { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 2,
                           'bucketx_content' => 2, 'buckety_content' => 96 }]
  end

  test 'error from spec' do
    assert_raise BucketCalculatorException do
      BucketCalculator.new(2, 6, 5)
    end
  end

  test 'equal1' do
    calculator = BucketCalculator.new(1, 8, 1)
    steps = calculator.calculate_steps
    assert steps.count == 1
    assert_equal steps, [{ :step => :fill, :bucket => 'bucketx', 'bucketx_content' => 1 }]
  end
  test 'equal2' do
    calculator = BucketCalculator.new(1, 8, 8)
    steps = calculator.calculate_steps
    assert steps.count == 1
    assert_equal steps, [{ :step => :fill, :bucket => 'buckety', 'buckety_content' => 8 }]
  end
  test 'too big' do
    assert_raise BucketCalculatorException do
      BucketCalculator.new(1, 2, 4)
    end
  end
  test 'have a solution but this algorithm cannot calculate' do
    # solution would be
    # fill bucket(5)
    # transfer from bucket(5) to bucket(3), now bucket(5) has 2
    # empty bucket(3)
    # transfer from bucket(5) to bucket(3) now bucket(3) has 2
    # fill bucket(5)
    # transfer from bucket(5) to bucket(3), now bucket(5) has 4
    assert_raise BucketCalculatorException do
      calculator = BucketCalculator.new(3, 5, 4)
      calculator.calculate_steps
    end
  end
end
