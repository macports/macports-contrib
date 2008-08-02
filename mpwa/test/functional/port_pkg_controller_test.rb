require File.dirname(__FILE__) + '/../test_helper'
require 'port_pkg_controller'

# Re-raise errors caught by the controller.
class PortPkgController; def rescue_action(e) raise e end; end

class PortPkgControllerTest < Test::Unit::TestCase
  fixtures :port_pkgs

  def setup
    @controller = PortPkgController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = port_pkgs(:first).id
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

    assert_not_nil assigns(:port_pkgs)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:port_pkg)
    assert assigns(:port_pkg).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:port_pkg)
  end

  def test_create
    num_port_pkgs = PortPkg.count

    post :create, :port_pkg => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_port_pkgs + 1, PortPkg.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:port_pkg)
    assert assigns(:port_pkg).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      PortPkg.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      PortPkg.find(@first_id)
    }
  end
end
