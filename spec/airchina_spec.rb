require 'flight_aggregator/airchina'

module FlightAggregator
  RSpec.describe AirChina do
    let(:browser) {  AirChina.new }
    let(:clickable) { double(:click => true) }
    before { allow(browser).to receive(:sleep) }

    context "search" do

      it "should navigate to the search page" do
        expect(browser).to receive(:visit).with(AirChina::PAGE)
        expect(browser).to receive(:find).with(AirChina::FORM) { clickable }

        browser.navigate
      end

      it "should fill the from field" do
        text_field = double("text_field")
        allow(text_field).to receive(:click)

        expect(browser).to receive(:find).with(:xpath, AirChina::FROM) { text_field }
        expect(text_field).to receive(:click)
        expect(text_field).to receive(:set).with("GRU")
        expect(browser).to receive(:find).with(AirChina::AUTOCOMPLETED_ITEM) { clickable }

        browser.fill_from "GRU"
      end

      it "should fill the to field" do
        text_field = double("text_field")
        allow(text_field).to receive(:click)

        expect(browser).to receive(:find).with(:xpath, AirChina::TO) { text_field }
        expect(text_field).to receive(:click)
        expect(text_field).to receive(:set).with("NRT")
        expect(browser).to receive(:find).with(AirChina::AUTOCOMPLETED_ITEM) { clickable }

        browser.fill_to "NRT"
      end

      it "should mark the flex dates" do
        expect(browser).to receive(:find).with(AirChina::FLEX_DATE) { clickable }
        expect(clickable).to receive(:checked?) { true }

        browser.check_flex_date
      end

      it "should fill the departure date" do
        allow(browser).to receive(:execute_script)

        date_field = double("date_field")

        expect(browser).to receive(:find).with(AirChina::DEPARTURE_DATE) { date_field }
        expect(date_field).to receive(:set).with("04/05/2015")

        browser.fill_departure_date Date.new(2015, 05, 04)
      end

      it "should fill the return_date" do
        allow(browser).to receive(:execute_script)

        date_field = double("date_field")

        expect(browser).to receive(:find).with(AirChina::RETURN_DATE) { date_field }
        expect(date_field).to receive(:set).with("27/05/2015")

        browser.fill_return_date Date.new(2015, 05, 27)
      end

      it "should submit form" do
        form = double(:find => clickable)

        expect(browser).to receive(:find).with(AirChina::FORM) { form }
        expect(form).to receive(:find).with(AirChina::SUBMIT) { clickable }

        browser.submit
      end

    end

    context "result page" do
      it "should parse the result into a matrix" do
        table = double("table")

        header = [double(:text => "24 May"), double(:text => "25 May")]

        tbody = [double('row_one'), double('row_two')]
        rows = [
          [double(:text => "01 May"), double(:text => "BRL 1000.00"), double(:text => "BRL 2000.00")],
          [double(:text => "02 May"), double(:text => "BRL 3000.00"), double(:text => "BRL 4000.00")]
        ]

        expect(browser).to receive(:find).with(AirChina::TABLE) { table }
        expect(table).to receive(:all).with(AirChina::TABLE_HEADER) { header }
        expect(table).to receive(:all).with(AirChina::TABLE_BODY) { tbody }

        rows.each_with_index do |row, index|
          date, *prices = row
          expect(tbody[index]).to receive(:find).with(AirChina::DATE_CELL) { date }
          expect(tbody[index]).to receive(:all).with(AirChina::VALUE_CELL) { prices }
        end

        fares = browser.parse_result

        expect(fares[0]).to eql(["AirChina", Date.new(2015, 05, 01), Date.new(2015, 05, 02)])
        expect(fares[1]).to eql([Date.new(2015, 05, 24), Money.new(100000, "BRL"), Money.new(300000, "BRL")])
        expect(fares[2]).to eql([Date.new(2015, 05, 25), Money.new(200000, "BRL"), Money.new(400000, "BRL")])
      end
    end
  end
end
