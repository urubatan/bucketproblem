require 'test_helper'

class BucketApiControllerTest < ActionDispatch::IntegrationTest # rubocop:disable Metrics/ClassLength
  test 'down' do
    post '/bucket_api', params: {
      x_capacity: 9,
      y_capacity: 2,
      z_amount_wanted: 5
    }, as: :json
    assert_response :success
    result = response.body
    assert_equal result, { solution:
                 [{ :step => :fill, :bucket => 'bucketx', 'bucketx_content' => 9 },
                  { :step => :transfer, :from => 'bucketx', :to => 'buckety', :transfer_amount => 2,
                    'buckety_content' => 2, 'bucketx_content' => 7 },
                  { step: :empty, bucket: 'buckety', bucket_content: 0 },
                  { :step => :transfer, :from => 'bucketx', :to => 'buckety', :transfer_amount => 2,
                    'buckety_content' => 2, 'bucketx_content' => 5, status: :solved }] }.to_json
  end
  test 'up' do
    post '/bucket_api', params: {
      x_capacity: 1,
      y_capacity: 8,
      z_amount_wanted: 5
    }, as: :json
    assert_response :success
    result = response.body
    assert_equal result, { solution:
                [{ :step => :fill, :bucket => 'buckety', 'buckety_content' => 8 },
                 { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 1,
                   'bucketx_content' => 1, 'buckety_content' => 7 },
                 { step: :empty, bucket: 'bucketx', bucket_content: 0 },
                 { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 1,
                   'bucketx_content' => 1, 'buckety_content' => 6 },
                 { step: :empty, bucket: 'bucketx', bucket_content: 0 },
                 { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 1,
                   'bucketx_content' => 1, 'buckety_content' => 5, status: :solved }] }.to_json
  end

  test 'first from spec' do
    post '/bucket_api', params: {
      x_capacity: 2,
      y_capacity: 10,
      z_amount_wanted: 4
    }, as: :json
    assert_response :success
    result = response.body
    assert_equal result, { solution:
                [{ :step => :fill, :bucket => 'bucketx', 'bucketx_content' => 2 },
                 { :step => :transfer, :from => 'bucketx', :to => 'buckety', :transfer_amount => 2,
                   'buckety_content' => 2, 'bucketx_content' => 0 },
                 { :step => :fill, :bucket => 'bucketx', 'bucketx_content' => 2 },
                 { :step => :transfer, :from => 'bucketx', :to => 'buckety', :transfer_amount => 2,
                   'buckety_content' => 4, 'bucketx_content' => 0, status: :solved }] }.to_json
  end
  test 'second from spec' do
    calculator = BucketCalculator.new(2, 100, 96)
    post '/bucket_api', params: {
      x_capacity: 2,
      y_capacity: 100,
      z_amount_wanted: 96
    }, as: :json
    assert_response :success
    result = response.body
    assert_equal result, { solution:
                [{ :step => :fill, :bucket => 'buckety', 'buckety_content' => 100 },
                 { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 2,
                   'bucketx_content' => 2, 'buckety_content' => 98 },
                 { step: :empty, bucket: 'bucketx', bucket_content: 0 },
                 { :step => :transfer, :from => 'buckety', :to => 'bucketx', :transfer_amount => 2,
                   'bucketx_content' => 2, 'buckety_content' => 96, status: :solved }] }.to_json
  end

  test 'equal1' do
    post '/bucket_api', params: {
      x_capacity: 1,
      y_capacity: 8,
      z_amount_wanted: 1
    }, as: :json
    assert_response :success
    result = response.body
    assert_equal result, { solution:
                [{ :step => :fill, :bucket => 'bucketx', 'bucketx_content' => 1, status: :solved }] }.to_json
  end
  test 'equal2' do
    post '/bucket_api', params: {
      x_capacity: 1,
      y_capacity: 8,
      z_amount_wanted: 8
    }, as: :json
    assert_response :success
    result = response.body
    assert_equal result, { solution:
                [{ :step => :fill, :bucket => 'buckety', 'buckety_content' => 8, status: :solved }] }.to_json
  end
  test 'too big' do
    post '/bucket_api', params: {
      x_capacity: 1,
      y_capacity: 2,
      z_amount_wanted: 4
    }, as: :json
    assert_response :unprocessable_entity
    result = JSON.parse(response.body).with_indifferent_access
    assert_pattern { result => { error: 'Impossible to calculate with the provided params'} }
  end
  test 'have a solution but this algorithm cannot calculate' do
    # solution would be
    # fill bucket(5)
    # transfer from bucket(5) to bucket(3), now bucket(5) has 2
    # empty bucket(3)
    # transfer from bucket(5) to bucket(3) now bucket(3) has 2
    # fill bucket(5)
    # transfer from bucket(5) to bucket(3), now bucket(5) has 4
    post '/bucket_api', params: {
      x_capacity: 3,
      y_capacity: 5,
      z_amount_wanted: 4
    }, as: :json
    assert_response :unprocessable_entity
    result = JSON.parse(response.body).with_indifferent_access
    assert_pattern { result => { error: 'Impossible to calculate with the provided params'} }
  end
  test 'non integer params' do
    post '/bucket_api', params: {
      x_capacity: 1,
      y_capacity: 2,
      z_amount_wanted: 'a'
    }, as: :json
    assert_response :unprocessable_entity
    result = JSON.parse(response.body).with_indifferent_access
    assert_pattern do
      result => { error: 'Invalid parameters received, valid parameters are: x_capacity, y_capacity and z_amount_wanted, and they must be positive integers'}
    end
  end
  test 'invalid parameter names' do
    post '/bucket_api', params: {
      rand1: 1,
      anything_else: 2,
      z_amount_wanted: 'a'
    }, as: :json
    assert_response :unprocessable_entity
    result = JSON.parse(response.body).with_indifferent_access
    assert_pattern do
      result => { error: 'Invalid parameters received, valid parameters are: x_capacity, y_capacity and z_amount_wanted, and they must be positive integers'}
    end
  end
  test 'error from spec' do
    post '/bucket_api', params: {
      x_capacity: 2,
      y_capacity: 6,
      z_amount_wanted: 5
    }, as: :json
    assert_response :unprocessable_entity
    result = JSON.parse(response.body).with_indifferent_access
    assert_pattern { result => { error: 'Impossible to calculate with the provided params'} }
  end
end
