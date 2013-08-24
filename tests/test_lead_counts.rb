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

    total = @client.element(css: '.summery h4')
    total.wait_until_present

    count = total.text
    assert_equal '3,417,210 households', count

    assert_facet_display_contains 'State:', 'All States'

  end

  def test_specific_state_selection

    new_york = @client.checkbox(value: 'ny')
    new_york.wait_until_present

    new_york.parent.checkbox.set

    total = @client.element(css: '.summery h4')
    total.wait_until_present

    count = total.text
    assert_equal '154 households', count

    assert_facet_display_contains 'State:', 'New York'
  end

  def test_zip_with_two_numbers_via_simple_text
    zip_link = @client.link(text: 'Zip Codes')
    zip_link.wait_until_present

    zip_link.click

    zip_list = @client.element(css: 'textarea').to_subtype
    zip_list.wait_until_present

    zip_list.focus

    @client.send_keys '06111'
    @client.send_keys :enter
    @client.send_keys '05403'

    @client.button(text: 'Use zip codes').click

    total = @client.element(css: '.summery h4')
    total.wait_until_present

    count = total.text
    assert_equal '12,804 households', count

    assert_facet_display_contains 'Zip codes:', '2 Zips'
  end

  def test_zip_numbers_via_simple_text
    zip_link = @client.link(text: 'Zip Codes')
    zip_link.wait_until_present

    zip_link.click

    zip_list = @client.element(css: 'textarea').to_subtype
    zip_list.wait_until_present

    zip_list.set '06111'

    @client.button(text: 'Use zip codes').click

    total = @client.element(css: '.summery h4')
    total.wait_until_present

    count = total.text
    assert_equal '8,256 households', count

    assert_facet_display_contains 'Zip codes:', '1 Zips'
  end

  def test_upload_zip_list
    zip_link = @client.link(text: 'Zip Codes')
    zip_link.wait_until_present
    zip_link.click

    @client.element(css: 'textarea').wait_until_present

    @client.execute_script("$('[name=file]').css({opacity:1})")

    zip_file = @client.file_field(name: 'file')
    zip_file.wait_until_present
    zip_file.set(File.expand_path(File.join(File.dirname(__FILE__), 'zip-list.txt')))

    sleep 1

    total = @client.element(css: '.summery h4')
    total.wait_until_present

    count = total.text
    assert_equal '8,256 households', count

    assert_facet_display_contains 'Zip codes:', '1 Zips'
  end

  def test_demographics_age_slider
    demographics = @client.link(text: 'Demographics')
    demographics.wait_until_present
    demographics.click

    @client.label(text: 'Age:').wait_until_present

    @client.execute_script("$('[data-facet-id=exact_age]').slider('value', 40, 60);$('[data-facet-id=exact_age]').slider().o.pointers[0].onmouseup();")

    count = get_count
    assert_equal '1,160,630 households', count

    assert_facet_display_contains 'Age:', '61 - 81'
  end

  def test_demographics_children_checkbox

    demographics = @client.link(text: 'Demographics')
    demographics.wait_until_present
    demographics.click

    children = @client.label(text: 'Children')
    children.wait_until_present

    children.parent.checkbox.set

    count = get_count
    assert_equal '1,455,825 households', count

    assert_facet_display_contains 'Children:', 'Yes'
  end

  def test_demographics_language_multiple_choice

    demographics = @client.link(text: 'Demographics')
    demographics.wait_until_present
    demographics.click

    language = @client.label(text: 'Language:')
    language.wait_until_present

    language.parent.element(css: 'input').to_subtype.focus

    @client.send_keys 'Eng'
    @client.send_keys :enter

    count = get_count
    assert_equal '3,019,664 households', count

    assert_facet_display_contains 'Language:', 'English'
  end

  def test_demographics_language_multiple_choice_select_many

    demographics = @client.link(text: 'Demographics')
    demographics.wait_until_present
    demographics.click

    language = @client.label(text: 'Language:')
    language.wait_until_present

    language.parent.element(css: 'input').to_subtype.focus

    @client.send_keys 'Eng'
    @client.send_keys :enter
    @client.send_keys 'Spa'
    @client.send_keys :enter

    count = get_count
    assert_equal '3,102,455 households', count

    assert_facet_display_contains 'Language:', %w(English Spanish)
  end

  def test_demographics_gender_select

    demographics = @client.link(text: 'Demographics')
    demographics.wait_until_present
    demographics.click

    language = @client.label(text: 'Gender:')
    language.wait_until_present

    language.parent.element(class: 'chzn-container').click

    @client.send_keys 'Ma'
    @client.send_keys :enter

    count = get_count
    assert_equal '2,020,875 households', count

    assert_facet_display_contains 'Gender:', 'Male'
  end

  def test_connect_rate

    responders = @client.button(text: 'Phone verified')
    responders.wait_until_present
    responders.click

    count = get_count
    assert_equal '42,981 households', count

    assert_facet_display_contains 'Response Level:', 'Phone verified'
  end

  def get_count
    total = @client.element(css: '.summery h4')
    total.wait_until_present

    total.text
  end

  def assert_facet_display_contains(label, text)
    if text.kind_of?(Array)
      text.each { |x| assert @client.element(text: x).exists? }
    else
      assert @client.element(text: text).exists?
    end

    assert @client.element(text: label).exists?
  end
end