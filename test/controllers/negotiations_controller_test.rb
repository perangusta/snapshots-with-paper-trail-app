require 'test_helper'

class NegotiationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @negotiation = negotiations(:one)
  end

  test "should get index" do
    get negotiations_url
    assert_response :success
  end

  test "should get new" do
    get new_negotiation_url
    assert_response :success
  end

  test "should create negotiation" do
    assert_difference('Negotiation.count') do
      post negotiations_url, params: { negotiation: { baseline: @negotiation.baseline, name: @negotiation.name, project_id: @negotiation.project_id, savings: @negotiation.savings, state: @negotiation.state } }
    end

    assert_redirected_to negotiation_url(Negotiation.last)
  end

  test "should show negotiation" do
    get negotiation_url(@negotiation)
    assert_response :success
  end

  test "should get edit" do
    get edit_negotiation_url(@negotiation)
    assert_response :success
  end

  test "should update negotiation" do
    patch negotiation_url(@negotiation), params: { negotiation: { baseline: @negotiation.baseline, name: @negotiation.name, project_id: @negotiation.project_id, savings: @negotiation.savings, state: @negotiation.state } }
    assert_redirected_to negotiation_url(@negotiation)
  end

  test "should destroy negotiation" do
    assert_difference('Negotiation.count', -1) do
      delete negotiation_url(@negotiation)
    end

    assert_redirected_to negotiations_url
  end
end
