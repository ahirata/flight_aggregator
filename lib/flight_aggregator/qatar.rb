require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'

module FlightAggregator
  class Qatar < Robot
    include Capybara::DSL

    HOST = 'http://www.qatarairways.com'
    PAGE = '/global/en/homepage.page'

    FORM = '#book'
    FROM = '#FromTemp'
    TO = '#ToTemp'
    AUTOCOMPLETED_ITEM = '#ui-active-menuitem'
    DEPARTURE_DATE = '#departing'
    RETURN_DATE = '#returning'
    SUBMIT = '#bookFlight'

    OUTBOUND = '#qOutBound'
    INBOUND = '#qInBound'

    DESTINATION = 'h3.sectionHeading'
    FARE = 'a.cubelnk'
    FARE_DEPARTURE = 'div.departureTime'
    FARE_PRICE = 'span.currHidden'
    FARE_CURRENCY = 'span.currCode'

    def navigate
      Capybara.app_host = HOST
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.javascript_driver = :webkit
      Capybara.default_wait_time = 15

      visit(PAGE)
      sleep 4

      find(FORM).click
      sleep 2
    end

    def fill_from from
      find(FROM).set(from)
      sleep 2

      find(AUTOCOMPLETED_ITEM).click
      sleep 2
    end

    def fill_to to
      find(TO).set(to)
      sleep 2

      find(AUTOCOMPLETED_ITEM).click
      sleep 2
    end

    def fill_departure_date date
      find(DEPARTURE_DATE).set(format_date(date))
    end

    def fill_return_date date
      find(RETURN_DATE).set(format_date(date))
    end

    def check_flex_date
    end

    def submit
      find(SUBMIT).click
      sleep 10
    end

    def parse_result
      outbound = parse_flights(find(OUTBOUND))
      inbound = parse_flights(find(INBOUND))

      build_matrix outbound, inbound
    end

    def parse_flights fieldset
      fieldset.all(FARE).map do |elem|
        date = Date.parse(elem.find(FARE_DEPARTURE).text)
        value = parse_value(elem.find(FARE_PRICE).text)
        currency = elem.find(FARE_CURRENCY).text

        Flight.new(self.class.name.split('::').last, date, Money.new(value, currency))
      end
    end

    def build_matrix outbound, inbound
      fare_matrix = []
      fare_matrix << [self.class.name.split('::').last, *outbound.map{|o| o.date}]
      fare_matrix.push(* inbound.map{|i| to_matrix_row(i, outbound)})
    end

    def to_matrix_row i, o
      [i.date].push(* o.map{|fare| fare.price + i.price})
    end

    def format_date date
      date.strftime('%d-%b-%Y')
    end

    def parse_value value
      value.delete(',.').to_f
    end
  end
end
