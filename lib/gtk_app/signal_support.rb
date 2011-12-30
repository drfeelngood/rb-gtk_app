module GtkApp
module SignalSupport

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    attr_reader :signal_connections

    # @param [Symbol] widget_name
    # @param [String] signal_name
    # @param [Symbol] receiver_method
    # @yield [...]
    def on(widget_name, signal_name, receiver_method=nil, &block)

      sc = SignalConnection.new do
        @widget_name = widget_name
        @signal_name = signal_name
        @receiver_method = receiver_method
        @receiver_block = block if block_given?
      end

      @signal_connections ||= []
      @signal_connections << sc
    end

  end
  
  module InstanceMethods

    def establish_signal_connections
      return unless self.class.signal_connections

      self.class.signal_connections.each do |signal_connection|
        signal_connection.with do |conn|
          widget = @view.send conn.widget_name
          if conn.receiver_block
            widget.signal_connect conn.signal_name do |*args|
              self.instance_exec(*args, &conn.receiver_block)
            end
          else
            widget.signal_connect conn.signal_name do |*args|
              self.send conn.receiver_method_name, *args
            end
          end
        end
      end
    end

  end

  class SignalConnection
    attr_accessor :widget_name, :signal_name
    attr_accessor :receiver_method, :receiver_block

    def initialize(&block)
      instance_eval(&block)
    end

    def with
      yield(self)
    end

  end

end
end