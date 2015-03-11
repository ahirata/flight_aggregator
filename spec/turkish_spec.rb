require 'flight_aggregator/turkish'

module FlightAggregator
  RSpec.describe Turkish do

    let (:browser) { Turkish.new }
    let(:clickable) { double(:click => true) }
    before { allow(browser).to receive(:sleep) }

    context "search" do

      it "should navigate to the search page" do
        expect(browser).to receive(:visit).with(Turkish::PAGE)
        expect(browser).to receive(:find).with(Turkish::FORM).and_return(clickable)

        browser.navigate
      end

      it "should fill the from field" do
        text_field = double("text_field")

        expect(browser).to receive(:find).with(Turkish::FROM).and_return(text_field)
        expect(text_field).to receive(:click)
        expect(text_field).to receive(:set).with("GRU")

        browser.fill_from "GRU"
      end

      it "should fill the to field" do
        text_field = double("text_field")
        allow(text_field).to receive(:click)

        expect(browser).to receive(:find).with(Turkish::TO).and_return(text_field)
        expect(text_field).to receive(:click)
        expect(text_field).to receive(:set).with("NRT")

        expect(browser).to receive(:find).with(Turkish::FORM).and_return(clickable)

        browser.fill_to "NRT"
      end

      it "should fill the departure date" do
        date_field = double("date_field")

        allow(browser).to receive(:execute_script)
        expect(browser).to receive(:find).with(Turkish::DEPARTURE_DATE).and_return(date_field)
        expect(date_field).to receive(:set).with("04.05.2015")

        browser.fill_departure_date Date.new(2015, 05, 04)
      end

      it "should fill the return date" do
        date_field = double("date_field")

        allow(browser).to receive(:execute_script)
        expect(browser).to receive(:find).with(Turkish::RETURN_DATE).and_return(date_field)
        expect(date_field).to receive(:set).with("27.05.2015")

        browser.fill_return_date Date.new(2015, 05, 27)
      end

      it "should submit the form" do
        form = double("form")
        allow(form).to receive(:click)
        expect(browser).to receive(:find).with(Turkish::FORM).and_return(form)
        expect(form).to receive(:find).with(Turkish::SUBMIT).and_return(clickable)

        browser.submit
      end

      context "result page" do
        it "should parse price table into a matrix" do
          Money.add_rate("USD", "BRL", 2.to_f)

          table = double("table")

          departure_dates = [double(:text => "01 May"), double(:text => "02 May")]

          tbody = [double("row_one"), double('row_two')]
          rows = [
            [double(:text => "24 May"), double(:text => "1,000 $"), double(:text => "2,000 $")],
            [double(:text => "25 May"), double(:text => "3,000 $"), double(:text => "4,000 $")]
          ]

          expect(table).to receive(:all).with(Turkish::TABLE_HEADER) { departure_dates }
          expect(table).to receive(:all).with(Turkish::TABLE_BODY) { tbody }

          tbody.each_with_index do |row, index|
            date, *prices = rows[index]
            expect(row).to receive(:find).with(Turkish::DATE_CELL) { date }
            expect(row).to receive(:all).with(Turkish::VALUE_CELL) { prices }
          end

          fares = browser.parse_fares table
          expect(fares[0]).to eql(["Turkish", Date.new(2015, 05, 01), Date.new(2015, 05, 02)])
          expect(fares[1]).to eql([Date.new(2015, 05, 24), Money.new(200000, "BRL"), Money.new(400000, "BRL")])
          expect(fares[2]).to eql([Date.new(2015, 05, 25), Money.new(600000, "BRL"), Money.new(800000, "BRL")])
        end
      end
    end
  end
end
