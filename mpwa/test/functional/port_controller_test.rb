require File.dirname(__FILE__) + '/../test_helper'
require 'port_controller'

# Re-raise errors caught by the controller.
class PortController; def rescue_action(e) raise e end; end

class PortControllerTest < Test::Unit::TestCase
  fixtures :ports

  def setup
    @controller = PortController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = ports(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:ports)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:port)
    assert assigns(:port).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:port)
  end

  def test_create
    num_ports = Port.count

    post :create, :port => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_ports + 1, Port.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:port)
    assert assigns(:port).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Port.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Port.find(@first_id)
    }
  end
end
