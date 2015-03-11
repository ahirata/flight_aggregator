require 'flight_aggregator/emirates'

module FlightAggregator
  RSpec.describe Emirates do
    let (:browser) { Emirates.new }
    let(:clickable) { double(:click => true) }
    before{ allow(browser).to receive(:sleep) }

    context "search" do

      it "should navigate to the search page" do
        expect(browser).to receive(:visit).with(Emirates::PAGE)

        expect(browser).to receive(:find).with(Emirates::FORM) { clickable }
        browser.navigate
      end

      it "should fill the from field" do
        text_field = double("text_field")
        allow(text_field).to receive(:click)

        expect(browser).to receive(:find).with(Emirates::FROM) { text_field }
        expect(text_field).to receive(:set).with("GRU")

        browser.fill_from "GRU"
      end

      it "should fill the to field" do
        text_field = double("text_field")
        allow(text_field).to receive(:click)
        expect(browser).to receive(:find).with(Emirates::TO) { text_field }
        expect(text_field).to receive(:set).with("NRT")

        browser.fill_to "NRT"
      end

      it "should fill the departure date" do
        date_field = double("date_field")

        expect(browser).to receive(:find).with(Emirates::DEPARTURE_DATE) { date_field }
        expect(date_field).to receive(:set).with("04 May 15")

        browser.fill_departure_date Date.new(2015, 05, 04)
      end

      it "should fill the return date" do
        date_field = double("date_field")

        expect(browser).to receive(:find).with(Emirates::RETURN_DATE) { date_field }
        expect(date_field).to receive(:set).with("27 May 15")

        browser.fill_return_date Date.new(2015, 05, 27)
      end

      it "should mkar the flex date" do
        expect(browser).to receive(:find).with(:xpath, Emirates::FLEX_DATE) { clickable }
        expect(clickable).to receive(:click)

        browser.check_flex_date
      end

      it "should submit the form" do
        expect(browser).to receive(:find).with(Emirates::SUBMIT) { clickable }

        browser.submit
      end

      context "result page" do
        it "should parse the result page into a matrix" do
          table = double("table")

          header = [double(:text => "01 May"), double(:text => "02 May")]
          rows = [
            [double(:text => "24 May"), double(:text => "BRL 1.000"), double(:text => "BRL 2.000")],
            [double(:text => "25 May"), double(:text =>"BRL 3.000"), double(:text => "BRL 4.000")]
          ]
          tbody = [double("row_one"), double("row_two")]

          expect(browser).to receive(:find).with(Emirates::TABLE) { table }

          expect(table).to receive(:all).with(Emirates::TABLE_HEADER) { header }
          expect(table).to receive(:all).with(Emirates::TABLE_BODY) { tbody }

          tbody.each_with_index do |row, row_index|
            date = double("date")
            prices = [double("price_on"), double("price_two")]

            expect(row).to receive(:all).with(Emirates::TABLE_CELL) { [date, *prices] }

            expect(date).to receive(:find).with(Emirates::DATE_CELL) { rows[row_index].first }
            prices.each_with_index do |price, price_index|
              expect(price).to receive(:has_selector?) { true }
              expect(price).to receive(:find).with(Emirates::VALUE_CELL) { rows[row_index][price_index + 1] }
            end
          end

          fares = browser.parse_result
          expect(fares[0]).to eql(["Emirates", Date.new(2015, 05, 01), Date.new(2015, 05, 02)])
          expect(fares[1]).to eql([Date.new(2015, 05, 24), Money.new(100000, "BRL"), Money.new(200000, "BRL")])
          expect(fares[2]).to eql([Date.new(2015, 05, 25), Money.new(300000, "BRL"), Money.new(400000, "BRL")])
        end
      end
    end
  end
end
