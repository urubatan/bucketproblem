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
                 [{ :step => :fill, :bucket => 'bucket1', 'bucket1_content' => 9 },
                  { :step => :transfer, :from => 'bucket1', :to => 'bucket2', :transfer_amount => 2,
                    'bucket2_content' => 2, 'bucket1_content' => 7 },
                  { step: :empty, bucket: 'bucket2', bucket_content: 0 },
                  { :step => :transfer, :from => 'bucket1', :to => 'bucket2', :transfer_amount => 2,
                    'bucket2_content' => 2, 'bucket1_content' => 5 }]
  end
  test 'up' do
    calculator = BucketCalculator.new(1, 8, 5)
    steps = calculator.calculate_steps
    assert steps.count > 1
    assert_equal steps,
                 [{ :step => :fill, :bucket => 'bucket2', 'bucket2_content' => 8 },
                  { :step => :transfer, :from => 'bucket2', :to => 'bucket1', :transfer_amount => 1,
                    'bucket1_content' => 1, 'bucket2_content' => 7 },
                  { step: :empty, bucket: 'bucket1', bucket_content: 0 },
                  { :step => :transfer, :from => 'bucket2', :to => 'bucket1', :transfer_amount => 1,
                    'bucket1_content' => 1, 'bucket2_content' => 6 },
                  { step: :empty, bucket: 'bucket1', bucket_content: 0 },
                  { :step => :transfer, :from => 'bucket2', :to => 'bucket1', :transfer_amount => 1,
                    'bucket1_content' => 1, 'bucket2_content' => 5 }]
  end
  test 'equal1' do
    calculator = BucketCalculator.new(1, 8, 1)
    steps = calculator.calculate_steps
    assert steps.count == 1
    assert_equal steps, [{ :step => :fill, :bucket => 'bucket1', 'bucket1_content' => 1 }]
  end
  test 'equal2' do
    calculator = BucketCalculator.new(1, 8, 8)
    steps = calculator.calculate_steps
    assert steps.count == 1
    assert_equal steps, [{ :step => :fill, :bucket => 'bucket2', 'bucket2_content' => 8 }]
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
