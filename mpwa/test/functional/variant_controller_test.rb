require File.dirname(__FILE__) + '/../test_helper'
require 'variant_controller'

# Re-raise errors caught by the controller.
class VariantController; def rescue_action(e) raise e end; end

class VariantControllerTest < Test::Unit::TestCase
  fixtures :variants

  def setup
    @controller = VariantController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = variants(:first).id
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

    assert_not_nil assigns(:variants)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:variant)
    assert assigns(:variant).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:variant)
  end

  def test_create
    num_variants = Variant.count

    post :create, :variant => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_variants + 1, Variant.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:variant)
    assert assigns(:variant).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Variant.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Variant.find(@first_id)
    }
  end
end
