require 'flight_aggregator'

module FlightAggregator
  RSpec.describe Agent do
    context "configuration" do
      it "should configure websites to scrape" do
        Configuration.configure do |config|
          config.sites << Qatar << Etihad
        end

        settings = Agent.new.settings

        expect(settings.sites.length).to eql(2)
        expect(settings.sites[0]).to eql(Qatar)
        expect(settings.sites[1]).to eql(Etihad)
      end

      it "should configure the trip" do
        Configuration.configure do |config|
          config.trip[:from] = "FROM"
          config.trip[:to] = "DESTINATION"
          config.trip[:departure_date] = Date.new(2015, 01, 01)
          config.trip[:return_date] = Date.new(2015, 02, 01)
        end

        settings = Agent.new.settings
        expect(settings.trip[:from]).to eql('FROM')
        expect(settings.trip[:to]).to eql('DESTINATION')
        expect(settings.trip[:departure_date]).to eql(Date.new(2015, 01, 01))
        expect(settings.trip[:return_date]).to eql(Date.new(2015, 02, 01))
      end

      it "should configure the mail details" do
        Configuration.configure do |config|
          config.mail = {
            :from => 'from_user',
            :to   => 'to_user'
          }
        end

        settings = Agent.new.settings

        expect(settings.mail[:from]).to eql('from_user')
        expect(settings.mail[:to]).to eql('to_user')
      end
    end
  end
end
