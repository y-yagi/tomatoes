require 'test_helper'

module Api
  class UsersControllerTest < ActionController::TestCase
    setup do
      @user = User.create!(name: 'name', email: 'email@example.com')
      @user.authorizations.create!(provider: 'tomatoes', token: '123')

      @user_without_auths = User.create!(name: 'Nicolae', email: 'nic@example.com')
    end

    teardown do
      User.destroy_all
    end

    test 'GET /show, given a nil token, it should return an error' do
      get :show
      assert_response :unauthorized
      assert_equal 'application/json', @response.content_type
      assert_equal({ error: 'authentication failed' }.to_json, @response.body)
    end

    test 'GET /show, given a blank token, it should return an error' do
      get :show, token: ''
      assert_response :unauthorized
      assert_equal 'application/json', @response.content_type
      assert_equal({ error: 'authentication failed' }.to_json, @response.body)
    end

    test 'GET /show, given an invalid token, it should return an error' do
      get :show, token: 'invalid_token'
      assert_response :unauthorized
      assert_equal 'application/json', @response.content_type
      assert_equal({ error: 'authentication failed' }.to_json, @response.body)
    end

    test 'GET /show, given a headr authorization token, it should return current user' do
      @request.headers['Authorization'] = '123'
      get :show
      assert_response :success
      assert_equal 'application/json', @response.content_type
      assert_equal Api::Presenter::User.new(@user).to_json, @response.body
    end

    test 'GET /show, it should return current user' do
      get :show, token: '123'
      assert_response :success
      assert_equal 'application/json', @response.content_type
      assert_equal Api::Presenter::User.new(@user).to_json, @response.body
    end

    test 'PATCH /update, given an invalid token, it should return an error' do
      patch :update, token: 'invalid_token', user: { name: 'Foo' }
      assert_response :unauthorized
      assert_equal 'application/json', @response.content_type
      assert_equal({ error: 'authentication failed' }.to_json, @response.body)
    end

    test 'PATCH /update, given valid params, it should update current user' do
      patch :update, token: '123', user: { name: 'Foo' }
      assert_response :success
      assert_equal 'application/json', @response.content_type
      @user.reload
      assert_equal Api::Presenter::User.new(@user).to_json, @response.body
      assert_match(/#{api_user_path}/, @response.headers['Location'])
      assert_equal 'Foo', @user.name
    end

    test 'PATCH /update, given a validation error, it should return an error' do
      @controller.stubs(:current_user).returns(@user)
      @user.expects(:update_attributes).returns(false)

      patch :update, token: '123', user: { name: 'Foo' }
      assert_response :unprocessable_entity
      assert_equal 'application/json', @response.content_type
    end
  end
end
