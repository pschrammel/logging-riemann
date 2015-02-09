require 'uri'
require 'socket'

module Logging
  module Appenders
    def self.riemann(*args)
      return Logging::Appenders::Riemann if args.empty?
      Logging::Appenders::Riemann.new(*args)
    end


    class Riemann < Logging::Appender
      DEFAULT_URI = "udp://localhost:5555"
      # @param option  accepts :uri like "udp://host:port", :host
      attr_reader :riemann_port, :riemann_host, :riemann_client

      def initialize(name,options={})
        uri=URI.parse(options[:uri] || DEFAULT_URI)
        @mapper=options[:mapper] || lambda do |hash|
        end
        @riemann_host= uri.host
        @riemann_port = uri.port
        @riemann_client=::Riemann::Client.new(:host => @riemann_host,
                                              :port => @riemann_port)
        @host=options.delete(:host) || Socket.gethostname
        super
      end


      def write(event)
        self.riemann_client << event2riemann_hash(event)
      end

      def event2riemann_hash(logging_event)
        riemann_event=if logging_event.data.kind_of?(Hash)
                        logging_event.data.dup
                      else
                        {:description => msg2str(logging_event.data)}
                      end


        @mapper.call(riemann_event)
        riemann_event[:state] ||= ::Logging::LNAMES[logging_event.level]
        riemann_event[:host] ||= @host
        riemann_event[:service] ||= @name
        riemann_event[:description] ||= logging_event.data[:message]
        riemann_event[:time] ||= logging_event.time.to_i

        #we don't overrdide given things from any context (mdc/ndc)
        Logging.mdc.context.each do |key, value|
          riemann_event[key] ||= value
        end

        Logging.ndc.context.each do |ctx|
          if ctx.respond_to?(:each)
            ctx.each do |key, value|
              riemann_event[key] ||= value
            end
          else
            riemann_event[ctx] ||= true #
          end
        end

        riemann_event
      end

      def msg2str(msg)
        case msg
          when ::String
            msg
          when ::Exception
            "#{ msg.message } (#{ msg.class })\n" <<
                (msg.backtrace || []).join("\n")
          else
            msg.inspect
        end
      end


    end


  end
end