require File.dirname(__FILE__) + '/../test_helper'
require 'file_refs_controller'

# Re-raise errors caught by the controller.
class FileRefsController; def rescue_action(e) raise e end; end

class FileRefsControllerTest < Test::Unit::TestCase
  fixtures :file_refs

  def setup
    @controller = FileRefsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = file_refs(:first).id
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

    assert_not_nil assigns(:file_refs)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:file_ref)
    assert assigns(:file_ref).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:file_ref)
  end

  def test_create
    num_file_refs = FileRef.count

    post :create, :file_ref => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_file_refs + 1, FileRef.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:file_ref)
    assert assigns(:file_ref).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      FileRef.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      FileRef.find(@first_id)
    }
  end
end
