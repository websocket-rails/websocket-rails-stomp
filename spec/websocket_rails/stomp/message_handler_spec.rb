require "spec_helper"

module WebsocketRails
  module Stomp
    describe MessageHandler do

      CONNECT_MESSAGE =<<EOF.strip_heredoc
CONNECT
login:undefined
passcode:undefined
host:test.host.com
accept-version:1.1,1.0
heart-beat:10000,10000

\0
EOF
      SUBSCRIBE_MESSAGE =<<EOF.strip_heredoc
CONNECT
destination:/queue/foo

\0
EOF

      let(:connection) { double("Conection") }
      let(:connect_message) { Frame.new(CONNECT_MESSAGE) }
      let(:subscribe_message) { Frame.new(SUBSCRIBE_MESSAGE) }
      let(:dispatcher) { double(WebsocketRails::Dispatcher).as_null_object }
      let(:connection) { double(WebsocketRails::Connection) }
      let(:connect_stomp_message) { Stomp::Message.new(connect_message, connection) }
      let(:connected_stomp_message) { Stomp::Message.connected(connect_message, connection) }
      subject { Stomp::MessageHandler.new(connection) }

      before do
        connection.stub(:dispatcher).and_return dispatcher
      end

      describe "#accepts?" do
        it "accepts the stomp protocol" do
          Stomp::MessageHandler.accepts?("stomp").should be_true
        end
      end

      describe "#on_open" do
        before do
          @message = Stomp::Message.new(connect_message, connection)
          Stomp::Message.stub(:deserialize).and_return @message
        end

        it "delegates to the #process_command method" do
          subject.should_receive(:process_command).with @message
          subject.on_open CONNECT_MESSAGE
        end
      end

      before do
        @message = Stomp::Message.new(subscribe_message, connection)
        Stomp::Message.stub(:deserialize).and_return @message
      end

      describe "#on_message" do
        it "delegates to the #process_command method" do
          subject.should_receive(:process_command).with @message
          subject.on_message SUBSCRIBE_MESSAGE
        end
      end

      describe "#on_close" do
        it "delegates to the #process_command method" do
          subject.should_receive(:process_command).with @message
          subject.on_close SUBSCRIBE_MESSAGE
        end
      end

      describe "#on_error" do
        it "delegates to the #process_command method" do
          subject.should_receive(:process_command).with @message
          subject.on_error SUBSCRIBE_MESSAGE
        end
      end

      describe "#process_command" do
        context "CONNECT" do
          before do
            @message = Stomp::Message.connected(connect_stomp_message, connection)
          end

          it "sends a CONNECTED message" do
            Stomp::Message.stub(:connected).and_return @message
            subject.should_receive(:trigger).with @message
            subject.process_command connect_stomp_message
          end
        end
      end

    end
  end
end
