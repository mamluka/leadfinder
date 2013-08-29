require 'mail'

Mail.defaults do
  retriever_method :pop3, :address => 'pop.gmx.com',
                   :port => 995,
                   :user_name => 'davidmz@gmx.co.uk',
                   :password => '095300acb',
                   :enable_ssl => true

end
Mail.delete_all