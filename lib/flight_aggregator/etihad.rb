require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'

module FlightAggregator
  class Etihad < Robot
    include Capybara::DSL

    HOST = 'http://www.etihad.com'
    PAGE = '/en-us'

    FORM = 'form#wrapper'

    FROM = '#frm_2012158061206151234'
    TO = '#frm_20121580612061235'
    AUTOCOMPLETED_ITEM = 'ul.ui-autocomplete li.ui-menu-item a'

    DEPARTURE_DATE = '#frm_2012158061206151238'
    RETURN_DATE = '#frm_2012158061206151239'
    SUBMIT = ".//button[@name='webform']"

    OUTBOUND = '#outbounds'
    INBOUND = '#inbounds'

    DESTINATION = 'div.flight-info dl'
    FARE = 'li.yuimenubaritem  '
    FARE_DEPARTURE = 'span.date'
    FARE_PRICE = 'span.prices-amount'
    FARE_CURRENCY = 'span.currency'

    def navigate
      Capybara.app_host = HOST
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.javascript_driver = :webkit
      Capybara.default_wait_time = 15

      visit(PAGE)
      sleep 10
    end

    def check_flex_date
    end

    def fill_from from
      from_field = find(FROM)
      from_field.click
      sleep 3

      from_field.set(from)
      sleep 3

      find(AUTOCOMPLETED_ITEM).click
      sleep 3
    end

    def fill_to to
      to_field = find(TO)
      to_field.click
      sleep 3

      to_field.set(to)
      sleep 3

      find(AUTOCOMPLETED_ITEM).click
      sleep 2
    end

    def fill_departure_date date
      find(DEPARTURE_DATE).set(format_date(date))
      sleep 2
    end

    def fill_return_date date
      find(RETURN_DATE).set(format_date(date))
      sleep 2

      find(FROM).click
    end

    def submit
      find(FORM).find(:xpath, SUBMIT).click
      sleep 4
    end

    def parse_result
      outbound = parse_flights(find(OUTBOUND))
      inbound = parse_flights(find(INBOUND))

      build_matrix outbound, inbound
    end

    def build_matrix outbound, inbound
      fare_matrix = []
      fare_matrix << [self.class.name.split('::').last].push(*outbound.map{|o| o.date})
      fare_matrix.push(*inbound.map{|i| to_matrix_row(i, outbound)})
    end

    def to_matrix_row i, outbound
      [i.date].push(* outbound.map{|o| o.price + i.price})
    end

    def parse_flights fieldset
      fieldset.all(FARE).map do |elem|
        date = Date.parse(elem.find(FARE_DEPARTURE).text)
        priceValue = parse_value(elem.find(FARE_PRICE).text)
        currency = elem.find(FARE_CURRENCY).text

        Flight.new(self.class.name.split('::').last, date, Money.new(priceValue, currency))
      end
    end

    def format_date date
      date.strftime('%d/%m/%Y')
    end

    def parse_value value
      value.delete(',.').to_f
    end
  end
end
