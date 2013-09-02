require 'minitest'
require "minitest/autorun"
require 'watir-webdriver'
require 'mail'
require 'rest-client'

require_relative 'core/login'

Mail.defaults do
  retriever_method :pop3, :address => 'pop.gmx.com',
                   :port => 995,
                   :user_name => 'davidmz@gmx.co.uk',
                   :password => '095300acb',
                   :enable_ssl => true
end

class Tests < Minitest::Test
  def setup
    @client = Watir::Browser.new :chrome
    @client.goto 'http://127.0.0.1'

    Mail.delete_all
  end

  def teardown
    @client.close
  end

  def test_basic_credit_card_payed_order_works

    all_states_label = @client.label(text: 'All States')
    all_states_label.wait_until_present

    all_states_label.parent.checkbox.set

    wait_until_count

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    lead_count = (100 + Random.rand(100)).to_s

    focus_input 'Your Order of'
    @client.send_keys lead_count

    focus_input 'Email'
    @client.send_keys 'davidmz@gmx.co.uk'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    focus_input 'Credit card number'
    @client.send_keys '4444333322221111'

    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:first'); select.val(1); select.trigger('change')"
    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:last'); select.val(15); select.trigger('change')"

    button = @client.button(text: 'Purchase Records')
    button.wait_until_present

    button.click

    assert_order_contains lead_count
  end

  def assert_order_contains(lead_count)
    download_url = get_download_url
    downloaded_file = RestClient.get download_url
    assert_equal lead_count.to_i, downloaded_file.scan(/\d{10}/).length
  end

  def test_suppression_when_ordering
    new_york = @client.checkbox(value: 'ny')
    new_york.wait_until_present

    new_york.parent.checkbox.set

    wait_until_count

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    lead_count = (114 + Random.rand(30)).to_s

    focus_input 'Your Order of'
    @client.send_keys lead_count

    @client.span(text: 'Upload suppression list(s)').click
    @client.span(text: 'No files uploaded yet').wait_until_present

    sleep 5

    @client.span(text: 'Done').click

    @client.execute_script "$('.file-field').show()"
    @client.file_field(class: 'file-field').set(File.expand_path(File.join(File.dirname(__FILE__), 'suppress.csv')))

    focus_input 'Email'
    @client.send_keys 'davidmz@gmx.co.uk'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    focus_input 'Credit card number'
    @client.send_keys '4444333322221111'

    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:first'); select.val(1); select.trigger('change')"
    @client.execute_script "var select = $('label:contains(Expiration date)').parent().find('select:last'); select.val(15); select.trigger('change')"

    button = @client.button(text: 'Purchase Records')
    button.wait_until_present
    button.click

    @client.element(css: 'h4').wait_until_present

    assert_order_contains 114
  end

  def test_download_when_unlimited
    login = Login.new @client
    login.unlimited_plan!
    login.login_linked_in!

    new_york = @client.checkbox(value: 'ny')
    new_york.wait_until_present

    new_york.parent.checkbox.set

    wait_until_count

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    lead_count = (114 + Random.rand(30)).to_s

    focus_input 'Your Order of'
    @client.send_keys lead_count

    focus_input 'Email'
    @client.text_field(name: 'email').set 'davidmz@gmx.co.uk'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    button = @client.button(text: 'Download')
    button.wait_until_present
    button.click

    assert_order_contains lead_count

  end

  def test_download_large_file
    login = Login.new @client
    login.unlimited_plan!
    login.login_linked_in!

    new_york = @client.checkbox(value: 'nh')
    new_york.wait_until_present

    new_york.parent.checkbox.set

    wait_until_count

    order_form = @client.link(text: 'Order form')
    order_form.wait_until_present
    order_form.click

    order_of = @client.label(text: 'Your Order of:')
    order_of.wait_until_present

    lead_count = (30000 + Random.rand(30)).to_s

    focus_input 'Your Order of'
    @client.send_keys lead_count

    focus_input 'Email'
    @client.text_field(name: 'email').set 'davidmz@gmx.co.uk'

    focus_input 'First name'
    @client.send_keys 'david'

    focus_input 'Last name'
    @client.send_keys 'mz'

    button = @client.button(text: 'Download')
    button.wait_until_present
    button.click

    assert_order_contains lead_count

  end


  def get_download_url
    until Mail.all.length > 0 && Mail.all.any? { |x| x.subject == 'ORDER CONFIRMATION' }
      p 'looking for email...'
      sleep 1
    end

    Mail.all.select { |x| x.subject == 'ORDER CONFIRMATION' }.first.body.to_s.scan(/http:\/\/.+.csv/).first
  end

  def focus_input(text)
    @client.execute_script "$('label:contains(#{text})').parent().find('input').focus()"
  end

  def wait_until_count
    total = @client.element(css: '.summery h4')
    total.wait_until_present
  end
end