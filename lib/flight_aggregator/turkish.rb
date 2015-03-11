require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'

module FlightAggregator
  class Turkish < Robot
    include Capybara::DSL

    HOST = 'http://www.turkishairlines.com'
    PAGE = '/en-br/'
    FORM = '#Main-Quick-Search-Ticket'

    FROM = '#from'
    TO = '#to'

    DEPARTURE_DATE = '#godate'
    RETURN_DATE = '#returndate'

    SUBMIT = 'button.submit_button'

    MATRIX_CHECK = '#idMatrixView'

    TABLE = '#matrixTable'
    TABLE_HEADER = 'tr > th.colhead'
    TABLE_BODY = 'tbody > tr'
    DATE_CELL = 'th.rowhead'
    VALUE_CELL = 'td'

    def check_flex_date
    end

    def navigate
      Capybara.app_host = HOST
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.javascript_driver = :webkit
      Capybara.default_wait_time = 20

      visit(PAGE)
      sleep 15
      find_form
    end

    def find_form
      form = find(FORM)
      form.click
      sleep 1
      form
    end

    def fill_from from
      from_field = find(FROM)
      from_field.click
      sleep 3

      from_field.set(from)
      sleep 3
    end

    def fill_to to
      to_field = find(TO)
      to_field.click
      sleep 3

      to_field.set(to)
      sleep 3

      find_form
    end

    def fill_departure_date date
      execute_script("$('#{DEPARTURE_DATE}').attr('readonly', false)")
      find(DEPARTURE_DATE).set(format_date(date))
    end

    def fill_return_date date
      execute_script("$('#{RETURN_DATE}').attr('readonly', false)")
      find(RETURN_DATE).set(format_date(date))
    end

    def submit
      find_form.find(SUBMIT).click
      sleep 15
    end

    def parse_result
      fares = []
      within_frame 0 do
        find(MATRIX_CHECK).click
        sleep 1

        fares = parse_fares(find(TABLE))
      end
      fares
    end

    def parse_fares table
      header = table.all(TABLE_HEADER)
      body = table.all(TABLE_BODY)

      fare_matrix = []
      fare_matrix << [
        self.class.name.split('::').last,
        *(header.map{|h| Date.parse(h.text)})
      ]
      fare_matrix.push(*(body.take(7).map{|row| to_matrix_row(row)}))
    end

    def to_matrix_row row
      [parse_date(row), *(row.all(VALUE_CELL).map{|fare| parse_fare(fare)})]
    end

    def parse_date row
      Date.parse(row.find(DATE_CELL).text)
    end

    def parse_fare fare
      price, symbol = fare.text.split(' ')
      Money.new(parse_value(price), 'USD').exchange_to('BRL')
    end

    def parse_value value
      value.delete(',.').to_f*100
    end

    def format_date date
      date.strftime('%d.%m.%Y')
    end

  end

end
