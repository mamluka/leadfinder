require 'backburner'

logger = Logger.new('jobs.log')

Backburner.configure do |config|
  config.beanstalk_url = %w(beanstalk://127.0.0.1)
  config.tube_namespace = 'leads-finder'
  config.on_error = lambda { |e| puts e }
  config.max_job_retries = 3 # default 0 retries
  config.retry_delay = 2 # default 5 seconds
  config.default_priority = 65536
  config.respond_timeout = 3600
  config.default_worker = Backburner::Workers::Simple
  config.logger = logger
end