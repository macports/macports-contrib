require File.dirname(__FILE__) + '/../test_helper'
require 'file_blob_controller'

# Re-raise errors caught by the controller.
class FileBlobController; def rescue_action(e) raise e end; end

class FileBlobControllerTest < Test::Unit::TestCase
  fixtures :file_blobs

  def setup
    @controller = FileBlobController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = file_blobs(:first).id
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

    assert_not_nil assigns(:file_blobs)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:file_blob)
    assert assigns(:file_blob).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:file_blob)
  end

  def test_create
    num_file_blobs = FileBlob.count

    post :create, :file_blob => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_file_blobs + 1, FileBlob.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:file_blob)
    assert assigns(:file_blob).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      FileBlob.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      FileBlob.find(@first_id)
    }
  end
end
