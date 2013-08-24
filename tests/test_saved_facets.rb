require 'minitest'
require "minitest/autorun"
require 'watir-webdriver'

class Tests < Minitest::Test
  def setup
    @client = Watir::Browser.new :chrome
    @client.goto 'http://127.0.0.1'
  end

  def teardown
    @client.close
  end

  def test_lead_counting
    all_states_label = @client.label(text: 'All States')
    all_states_label.wait_until_present

    all_states_label.parent.checkbox.set
    get_count

    @client.refresh

    count = get_count

    assert_equal '3,417,210 households', count
  end

  def test_zip_via_simple_text
    zip_link = @client.link(text: 'Zip Codes')
    zip_link.wait_until_present

    zip_link.click

    zip_list = @client.element(css: 'textarea').to_subtype
    zip_list.wait_until_present

    zip_list.set '06111'

    @client.button(text: 'Use zip codes').click
    get_count

    @client.refresh

    count = get_count
    assert_equal '8,256 households', count

  end

  def get_count
    total = @client.element(css: '.summery h4')
    total.wait_until_present

    total.text
  end
end