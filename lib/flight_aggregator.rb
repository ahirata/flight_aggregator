require 'date'
require 'erb'
require 'money'
require 'money/bank/google_currency'

module FlightAggregator
  class Settings
    attr_accessor :trip, :mail, :sites

    def initialize
      Money.default_bank = Money::Bank::GoogleCurrency.new
      Money.default_currency = Money::Currency.new("BRL")
      Money.use_i18n = false

      @sites = []
      @trip = {}
      @mail = {}
    end

    def trip_configured?
      !@trip[:from].nil? && !@trip[:to].nil? &&
        !@trip[:departure_date].nil? && !@trip[:return_date].nil?
    end

    def mail_configured?
      !@mail[:from].nil? && !@mail[:to].nil?
    end
  end

  module Configuration
    @settings = Settings.new
    def self.configure
      yield(@settings)
    end

    def self.settings
      @settings
    end
  end

  class Robot
    def fetch trip
      navigate

      fill_from trip[:from]
      fill_to trip[:to]
      check_flex_date
      fill_departure_date trip[:departure_date]
      fill_return_date trip[:return_date]
      submit

      parse_result
    end
  end

  class Flight
    attr_reader :company, :date, :price

    def initialize(company, date, price)
      @company = company
      @date = date
      @price = price
    end

    def eql? o
      o.company.eql?(@company) &&
        o.date.eql?(@date) &&
        o.price.eql?(@price)
    end
  end

  class Agent
    attr_accessor :settings

    def initialize
      @settings = FlightAggregator::Configuration.settings
    end

    def report
      if !settings.trip_configured?
        puts 'Configuration missing. Check ./conf/config.rb'
        exit 1
      end

      result = settings.sites.map do |site|
        site.new.fetch(settings.trip)
      end

      render_html(result) do |page|
        if settings.mail_configured?
          send_mail("Precos #{DateTime.now.strftime('%d %b %y %H:%M')}", page, settings)
        else
          puts page
        end
      end
    end

    def render_html fares
      b = binding
      b.local_variable_set(:companies, fares)
      yield ERB.new(File.read(File.dirname(__FILE__) + '/flight_aggregator/template.erb'), nil, '>').result(b)
    end

    def send_mail title, page, settings
      Mail.deliver do
        from settings.mail[:from]
        to   settings.mail[:to]
        subject title
        html_part do
          content_type 'text/html; charset=UTF-8'
          body page
        end
      end
    end
  end
end

