require_relative '../../api/core/orm'

class Login
  def initialize(client)
    @client = client
  end

  def login_linked_in!
    login_link = @client.link(text: 'Login')
    login_link.wait_until_present
    login_link.click

    linked_in = @client.element(css: '.modal img')
    linked_in.wait_until_present

    sleep 1

    linked_in.click

    linked_in_login = @client.text_field(name: 'session_key')
    linked_in_login.wait_until_present

    linked_in_login.set 'david.mazvovsky@gmail.com'
    @client.text_field(name: 'session_password').set '0953acb'

    @client.button(name: 'authorize').click
  end

  def unlimited_plan!
    user = User.new(
        email:'david.mazvovsky@gmail.com',
        plan:'unlimited'
    )
    user.upsert

  end
end