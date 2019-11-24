require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
    @project = projects(:one)
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post projects_url, params: { project: { baseline: @project.baseline, description: @project.description, end_on: @project.end_on, name: @project.name, savings: @project.savings, start_on: @project.start_on, state: @project.state } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "should show project" do
    get project_url(@project)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    patch project_url(@project), params: { project: { baseline: @project.baseline, description: @project.description, end_on: @project.end_on, name: @project.name, savings: @project.savings, start_on: @project.start_on, state: @project.state } }
    assert_redirected_to project_url(@project)
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end
end
