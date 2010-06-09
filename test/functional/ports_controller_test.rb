require 'test_helper'

class PortsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create port" do
    assert_difference('Port.count') do
      post :create, :port => { }
    end

    assert_redirected_to port_path(assigns(:port))
  end

  test "should show port" do
    get :show, :id => ports(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => ports(:one).to_param
    assert_response :success
  end

  test "should update port" do
    put :update, :id => ports(:one).to_param, :port => { }
    assert_redirected_to port_path(assigns(:port))
  end

  test "should destroy port" do
    assert_difference('Port.count', -1) do
      delete :destroy, :id => ports(:one).to_param
    end

    assert_redirected_to ports_path
  end
end
