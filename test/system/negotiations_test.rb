require "application_system_test_case"

class NegotiationsTest < ApplicationSystemTestCase
  setup do
    @negotiation = negotiations(:one)
  end

  test "visiting the index" do
    visit negotiations_url
    assert_selector "h1", text: "Negotiations"
  end

  test "creating a Negotiation" do
    visit negotiations_url
    click_on "New Negotiation"

    fill_in "Baseline", with: @negotiation.baseline
    fill_in "Name", with: @negotiation.name
    fill_in "Project", with: @negotiation.project_id
    fill_in "Savings", with: @negotiation.savings
    fill_in "State", with: @negotiation.state
    click_on "Create Negotiation"

    assert_text "Negotiation was successfully created"
    click_on "Back"
  end

  test "updating a Negotiation" do
    visit negotiations_url
    click_on "Edit", match: :first

    fill_in "Baseline", with: @negotiation.baseline
    fill_in "Name", with: @negotiation.name
    fill_in "Project", with: @negotiation.project_id
    fill_in "Savings", with: @negotiation.savings
    fill_in "State", with: @negotiation.state
    click_on "Update Negotiation"

    assert_text "Negotiation was successfully updated"
    click_on "Back"
  end

  test "destroying a Negotiation" do
    visit negotiations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Negotiation was successfully destroyed"
  end
end
