require 'minitest'
require "minitest/autorun"
require 'watir-webdriver'

class Tests < Minitest::Test
  def setup
    @client = Watir::Browser.new :chrome
    @client.goto 'http://leadfinder'
  end

  def teardown
    @client.close
  end

  def test_lead_counting_works
    all_states_label = @client.label(text: 'All States')
    all_states_label.wait_until_present

    all_states_label.parent.checkbox.set

    count = @client.element(css: '.summery h4').text

    assert_equal count, '3,417,210 households'
  end
end