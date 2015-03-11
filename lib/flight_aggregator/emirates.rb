require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'

module FlightAggregator
  class Emirates < Robot
    include Capybara::DSL

    HOST = 'http://www.emirates.com'
    PAGE = '/english/'
    FORM = 'a.customBtn.button-flight-search'

    FROM = '#seldcity1-suggest'
    TO = '#selacity1-suggest'

    DEPARTURE_DATE = '#selddate1'
    RETURN_DATE = '#seladate1'
    FLEX_DATE = "//div[@id='myDates']/div/div"

    SUBMIT = '#btnStartBooking'

    TABLE = '#ctl00_c_gridTableMain'
    TABLE_HEADER = 'tr > th:not(:first-child) > p'
    TABLE_BODY = 'tr:not(:first-child)'
    TABLE_CELL = 'td'
    DATE_CELL = 'p'
    VALUE_CELL = 'span.fare-currency-container'

    def navigate
      Capybara.app_host = HOST
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.javascript_driver = :webkit
      Capybara.default_wait_time = 20

      visit(PAGE)
      sleep 10

      find(FORM).click
      sleep 3
    end

    def fill_from from
      fromField = find(FROM)
      fromField.click
      sleep 3

      fromField.set(from)
      sleep 3
    end

    def fill_to to
      toField = find(TO)
      toField.click
      sleep 3

      toField.set(to)
      sleep 3
    end

    def check_flex_date
      find(:xpath, FLEX_DATE).click
    end

    def fill_departure_date date
      find(DEPARTURE_DATE).set(format_date(date))
    end

    def fill_return_date date
      find(RETURN_DATE).set(format_date(date))
    end

    def submit
      find(SUBMIT).click
      sleep 10
    end

    def parse_result
      return parse_fares(find(TABLE))
    end

    def parse_fares table
      header = table.all(TABLE_HEADER)
      rows = table.all(TABLE_BODY)

      fare_matrix = []

      fare_matrix << [
        self.class.name.split('::').last,
        *(header.map{|h| Date.parse(h.text)})
      ]
      fare_matrix.push(*(rows.map{|row| to_matrix_row(row)}))
    end

    def to_matrix_row row
      cells = row.all(TABLE_CELL)
      [parse_date(cells.first), *(cells.drop(1).map{|fare| parse_fare(fare)})]
    end

    def parse_date cell
      Date.parse(cell.find(DATE_CELL).text)
    end

    def parse_fare fare
      symbol, price = if fare.has_selector?(VALUE_CELL)
                        fare.find(VALUE_CELL).text.split(' ')
                      else
                        ['BRL', '0']
                      end
      Money.new(parse_value(price), symbol)
    end

    def parse_value value
      value.delete(',.').to_f*100
    end

    def format_date date
      date.strftime('%d %b %y')
    end
  end
end
