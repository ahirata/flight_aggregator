require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'

module FlightAggregator
  class AirChina < Robot
    include Capybara::DSL

    HOST = 'https://www.airchina.com.br'
    PAGE = '/BR/GB/Home'
    FORM = '#flightSearch'

    FROM = "//input[@name='FSB1FromSource']"
    TO = "//input[@name='FSB1ToDestination']"
    AUTOCOMPLETED_ITEM = 'ul.ui-autocomplete li.ui-menu-item a'

    DEPARTURE_DATE = '#flightDpt'
    RETURN_DATE = '#flightArr'
    FLEX_DATE = '#flexCheck'

    SUBMIT = 'button.fssubmit'

    TABLE = 'table.ffcr-fare'
    TABLE_HEADER = 'tr.weekDay > th'
    TABLE_BODY = 'tbody > tr'
    DATE_CELL = 'th.weekDay'
    VALUE_CELL = 'td'

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
      from_field = find(:xpath, FROM)
      from_field.click
      sleep 3

      from_field.set(from)
      sleep 3

      find(AUTOCOMPLETED_ITEM).click
      sleep 3
    end

    def fill_to to
      to_field = find(:xpath, TO)
      to_field.click
      sleep 3

      to_field.set(to)
      sleep 3

      find(AUTOCOMPLETED_ITEM).click
    end

    def check_flex_date
      flex_check = find(FLEX_DATE)
      if !flex_check.checked?
        flex_check.click
      end
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
      find(FORM).find(SUBMIT).click
      sleep 15
    end

    def parse_result
      parse_fares(find(TABLE))
    end

    def parse_fares table
      header = table.all(TABLE_HEADER)
      body = table.all(TABLE_BODY)

      fare_matrix = []
      fare_matrix << [
        self.class.name.split('::').last,
        *(header.map{|h| Date.parse(h.text)})
      ]
      fare_matrix.push(*body.map{|row| to_matrix_row(row)})

      fare_matrix.transpose
    end

    def to_matrix_row row
      date = row.find(DATE_CELL).text
      cells = row.all(VALUE_CELL)
      [Date.parse(date), *(cells.map{|fare| parse_fare(fare.text)})]
    end

    def parse_fare fare
      symbol, price = fare.split(' ')
      Money.new(parse_value(price), symbol)
    end

    def parse_value value
      value.delete(',.')
    end

    def format_date date
      date.strftime('%d/%m/%Y')
    end

  end
end
