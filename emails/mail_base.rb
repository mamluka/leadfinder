require 'action_mailer'
require 'json'

module Emails
  module Config
    def Config.get_config(config_file_name)
      JSON.parse(File.read(File.dirname(__FILE__) + '/../config/' + config_file_name + '.json'))
    end

    def get_config(config_file_name)
      Config.get_config config_file_name
    end
  end
end

class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr("-", "_").
        downcase
  end
end

config = Emails::Config.get_config 'emails'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address => config['host'],
    :port => 587,
    :domain => config['domain'],
    :authentication => :plain,
    :user_name => config['username'],
    :password => config['password'],
    :enable_starttls_auto => true
}
ActionMailer::Base.view_paths= File.dirname(__FILE__)

class EmailBase < ActionMailer::Base
  include Emails::Config

  def prepare_email(options)

    from = 'Leadfinder <data@flowmediacorp.com>'

    emailing_options = {:to => options[:to],
                        :from => from,
                        :subject => options[:subject],
                        :reply_to => from}

    if File.exist?(File.dirname(__FILE__) + "/#{self.class.name.underscore}/#{caller[0][/`.*'/][1..-2]}.html.erb")
      mail(emailing_options) do |format|
        format.text
        format.html
      end
    else
      mail(emailing_options) do |format|
        format.text
      end
    end
  end
end


require_relative 'order'
require_relative 'contact-us'