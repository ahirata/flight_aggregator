require 'mail'
require_relative '../lib/flight_aggregator'
require_relative '../lib/flight_aggregator'
require_relative '../lib/flight_aggregator/airchina'
require_relative '../lib/flight_aggregator/emirates'
require_relative '../lib/flight_aggregator/etihad'
require_relative '../lib/flight_aggregator/qatar'
require_relative '../lib/flight_aggregator/turkish'

# FlightAggregator::Configuration.configure do |conf|
#   conf.sites = [FlightAggregator::AirChina, FlightAggregator::Emirates, FlightAggregator::Etihad, FlightAggregator::Qatar, FlightAggregator::Turkish]
#   conf.trip = {
#     :from => "GRU", # airport code
#     :to   => "NRT", # airpor code
#     :departure_date => Date.new(2015, 06, 01),
#     :return_date    => Date.new(2015, 07, 01)
#   }
#   conf.mail = {
#     :from => 'User <user@domain.com>',
#     :to   => ['rcpt@domain.com']
#   }
#   Mail.defaults do
#     delivery_method :smtp, {
#       :address => 'smtp.mail.domain.com',
#       :port => 465,
#       :domain => 'localhost',
#       :user_name => 'user@domain.com',
#       :password => 'user-secret-password',
#       :ssl => true,
#       :enable_starttls_auto => true
#     }
#   end
# end


