require 'backburner'
require_relative 'create-csv-for-customer'
require_relative '../core/queue'

Backburner.work('leads-finder.orders')