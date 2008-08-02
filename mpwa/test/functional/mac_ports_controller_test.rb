require File.dirname(__FILE__) + '/../test_helper'
require 'mac_ports_controller'

# Re-raise errors caught by the controller.
class MacPortsController; def rescue_action(e) raise e end; end

class MacPortsControllerTest < Test::Unit::TestCase
  def setup
    @controller = MacPortsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
