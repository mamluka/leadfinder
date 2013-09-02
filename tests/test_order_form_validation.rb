require 'minitest'
require "minitest/autorun"
require 'watir-webdriver'

require_relative 'core/login'

class Tests < Minitest::Test
  def setup
    @client = Watir::Browser.new :chrome
    @client.goto 'http://127.0.0.1'
  end

  def teardown
    @client.close
  end

  def test_order_form_validation_should_work_when_regular_cc_buying
    all_states_label = @client.label(text: 'All States')
    all_states_label.wait_until_present

    all_states_label.parent.checkbox.set

    wait_until_count

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    focus_input 'Your Order of'
    @client.send_keys '1000'

    assert_form_invalid

    focus_input 'Email'
    @client.send_keys 'cool@cool.com'

    assert_form_invalid

    focus_input 'First name'
    @client.send_keys 'david'

    assert_form_invalid

    focus_input 'Last name'
    @client.send_keys 'mz'

    assert_form_invalid

    focus_input 'Credit card number'
    @client.send_keys '4916345284667239'

    assert_form_invalid

    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:first'); select.val(2); select.trigger('change')"
    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:last'); select.val(13); select.trigger('change')"

    assert_form_valid
  end

  def test_cant_order_more_then_1000000
    all_states_label = @client.label(text: 'All States')
    all_states_label.wait_until_present

    all_states_label.parent.checkbox.set

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    focus_input 'Your Order of'
    @client.send_keys '1000001'

    focus_input 'Email'
    @client.send_keys 'cool@cool.com'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    focus_input 'Credit card number'
    @client.send_keys '4916345284667239'

    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:first'); select.val(2); select.trigger('change')"
    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:last'); select.val(13); select.trigger('change')"

    assert_form_invalid
  end

  def test_cant_order_more_then_leads_exist
    new_york = @client.checkbox(value: 'ny')
    new_york.wait_until_present

    new_york.parent.checkbox.set

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    focus_input 'Your Order of'
    @client.send_keys '1000'

    focus_input 'Email'
    @client.send_keys 'cool@cool.com'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    focus_input 'Credit card number'
    @client.send_keys '4916345284667239'

    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:first'); select.val(2); select.trigger('change')"
    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:last'); select.val(13); select.trigger('change')"

    assert_form_invalid
  end

  def test_email_validation_works
    new_york = @client.checkbox(value: 'ny')
    new_york.wait_until_present

    new_york.parent.checkbox.set

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    focus_input 'Your Order of'
    @client.send_keys '100'

    focus_input 'Email'
    @client.send_keys 'cool@cool'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    focus_input 'Credit card number'
    @client.send_keys '4916345284667239'

    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:first'); select.val(2); select.trigger('change')"
    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:last'); select.val(13); select.trigger('change')"

    assert_form_invalid
    end

  def test_when_number_of_leads_is_zero_should_not_be_valid
    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    focus_input 'Your Order of'
    @client.send_keys '100'

    focus_input 'Email'
    @client.send_keys 'cool@cool.com'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    focus_input 'Credit card number'
    @client.send_keys '4916345284667239'

    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:first'); select.val(2); select.trigger('change')"
    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:last'); select.val(13); select.trigger('change')"

    assert_form_invalid
  end

  def credit_card_validation_works
    new_york = @client.checkbox(value: 'ny')
    new_york.wait_until_present

    new_york.parent.checkbox.set

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    focus_input 'Your Order of'
    @client.send_keys '100'

    focus_input 'Email'
    @client.send_keys 'cool@cool.com'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    focus_input 'Credit card number'
    @client.send_keys '4916345284667231'

    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:first'); select.val(2); select.trigger('change')"
    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:last'); select.val(13); select.trigger('change')"

    assert_form_invalid
  end

  def test_validation_works_when_unlimited_plan

    login = Login.new @client
    login.unlimited_plan!
    login.login_linked_in!

    all_states_label = @client.label(text: 'All States')
    all_states_label.wait_until_present

    all_states_label.parent.checkbox.set

    wait_until_count

    order_form = @client.link(text: 'Order form')
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    focus_input 'Your Order of'
    @client.send_keys '100'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    assert_unlimited_form_valid
  end

  def test_validation_invalid_form_when_name_missing

    login = Login.new @client
    login.unlimited_plan!
    login.login_linked_in!

    all_states_label = @client.label(text: 'All States')
    all_states_label.wait_until_present

    all_states_label.parent.checkbox.set

    order_form = @client.link(text: 'Order form')
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    focus_input 'Your Order of'
    @client.send_keys '100'

    focus_input 'Last name'
    @client.send_keys 'mz'

    assert_unlimited_form_invalid
  end

  def assert_form_invalid
    button = @client.button(text: 'Purchase Records')
    button.wait_until_present

    assert !button.enabled?
  end

  def assert_form_valid
    button = @client.button(text: 'Purchase Records')
    button.wait_until_present

    assert button.enabled?
  end

  def assert_unlimited_form_invalid
    button = @client.button(text: 'Download')
    button.wait_until_present

    assert !button.enabled?
  end

  def assert_unlimited_form_valid
    button = @client.button(text: 'Download')
    button.wait_until_present

    assert button.enabled?
  end

  def focus_input(text)
    @client.execute_script "$('label:contains(#{text})').parent().find('input').focus()"
  end
  def wait_until_count
    total = @client.element(css: '.summery h4')
    total.wait_until_present
  end
end