RSpec.describe Logging::Appenders::Riemann do
  before do
    @now=Timecop.freeze(Time.local(2014, 12, 10, 10, 20, 19))
    Logging.mdc.clear
    Logging.ndc.clear
  end

  it "registers the riemann appender" do
    expect(Logging::Appenders.riemann("metric")).to be_kind_of(Logging::Appenders::Riemann)
  end
  it "parses a uri" do
    logger=Logging::Appenders::Riemann.new("metric",:uri => "udp://myhost:5554")
    expect(logger.riemann_host).to eq("myhost")
    expect(logger.riemann_port).to eq(5554)
  end
  it "has a default uri" do
    logger=Logging::Appenders::Riemann.new("metric")
    expect(logger.riemann_host).to eq("localhost")
    expect(logger.riemann_port).to eq(5555)
  end

  describe "event" do
    let(:appender) do
      Logging::Appenders::Riemann.new("metric",:host => "myhost")
    end
    let(:logger) {
      log = Logging.logger['example_logger']
      log.add_appenders(appender)
      log.level = :info
      log
    }

    it "creates a hash for event" do
      hash=appender.event2riemann_hash(Logging::LogEvent.new("test",1,{:arg => "value"},false))
      expect(hash).to eq(:arg=>"value",
                          :sate=>"INFO",
                          :host=>"myhost",
                          :service=>"metric",
                          :description=>nil,
                          :time=>@now.to_i)
    end

    it "create a reimann event" do
      expect(appender.riemann_client).to receive(:<<).
                                             with({:description=>"wooha",
                                                   :sate=>"INFO",
                                                   :host=>"myhost",
                                                   :service=>"metric",
                                                   :time=>@now.to_i})
      logger.info("wooha")
    end
  end

end
