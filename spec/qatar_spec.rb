require 'flight_aggregator/qatar'

module FlightAggregator
  RSpec.describe Qatar do

    let(:browser) { Qatar.new }
    let(:clickable) { double(:click => true) }

    before { allow(browser).to receive(:sleep) }

    context "search" do

      it "should navigate to the search page" do
        expect(browser).to receive(:visit).with(Qatar::PAGE)
        expect(browser).to receive(:find).with(Qatar::FORM) { clickable }

        browser.navigate
      end

      it "should fill the from field" do
        text_field = double("text_field")

        expect(browser).to receive(:find).with(Qatar::FROM) { text_field }
        expect(text_field).to receive(:set).with("GRU")
        expect(browser).to receive(:find).with(Qatar::AUTOCOMPLETED_ITEM) { clickable }

        browser.fill_from "GRU"
      end

      it "should fill the to field" do
        text_field = double("text_field")

        expect(browser).to receive(:find).with(Qatar::TO) { text_field }
        expect(text_field).to receive(:set).with("NRT")
        expect(browser).to receive(:find).with(Qatar::AUTOCOMPLETED_ITEM) { clickable }

        browser.fill_to "NRT"
      end

      it "should fill the departure date" do
        date_field = double("date_field")

        expect(browser).to receive(:find).with(Qatar::DEPARTURE_DATE) { date_field }
        expect(date_field).to receive(:set).with("04-May-2015")

        browser.fill_departure_date Date.new(2015, 05, 04)
      end

      it "should fill the return date" do
        date_field = double("date_field")

        expect(browser).to receive(:find).with(Qatar::RETURN_DATE) { date_field }
        expect(date_field).to receive(:set).with("27-May-2015")

        browser.fill_return_date Date.new(2015, 05, 27)
      end

      it "should submit the form" do
        expect(browser).to receive(:find).with(Qatar::SUBMIT) { clickable }

        browser.submit
      end
    end

    context "result page" do
      it "should read flight section" do
        inbound = double("flight section")

        dates = [double(:text => "01 May"), double(:text => "02 May")]
        prices = [double(:text => "1,000.00"), double(:text => "2,000.00")]
        currencies = [double(:text => "BRL"), double(:text => "BRL")]

        flights = [double("flight_one"), double("flight_two")]
        expect(inbound).to receive(:all).with(Qatar::FARE) { flights }

        flights.each_with_index do |flight, index|
          expect(flight).to receive(:find).with(Qatar::FARE_DEPARTURE) { dates[index] }
          expect(flight).to receive(:find).with(Qatar::FARE_PRICE) { prices[index] }
          expect(flight).to receive(:find).with(Qatar::FARE_CURRENCY) { currencies[index] }
        end

        flights = browser.parse_flights inbound
        expect(flights[0]).to eql(Flight.new("Qatar", Date.new(2015, 05, 01), Money.new(100000, "BRL")))
        expect(flights[1]).to eql(Flight.new("Qatar", Date.new(2015, 05, 02), Money.new(200000, "BRL")))
      end

      it "should transform the result into a matrix" do
        outbound = [
          Flight.new("Qatar", Date.new(2015, 05, 01), Money.new(1000, "BRL")),
          Flight.new("Qatar", Date.new(2015, 05, 02), Money.new(2000, "BRL")),
        ]
        inbound = [
          Flight.new("Qatar", Date.new(2015, 05, 22), Money.new(500, "BRL")),
          Flight.new("Qatar", Date.new(2015, 05, 23), Money.new(600, "BRL")),
        ]

        fares = browser.build_matrix outbound, inbound

        expect(fares[0]).to eql(["Qatar", Date.new(2015, 05, 01), Date.new(2015, 05, 02)])
        expect(fares[1]).to eql([Date.new(2015, 05, 22), Money.new(1500, "BRL"), Money.new(2500, "BRL")])
        expect(fares[2]).to eql([Date.new(2015, 05, 23), Money.new(1600, "BRL"), Money.new(2600, "BRL")])
      end
    end
  end
end
