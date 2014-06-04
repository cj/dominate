require "observer"

module Dominate
  class Widget
    class Event < Struct.new(:res, :req)
      include Observable

      def trigger widget_name, widget_event, data = {}
        # THIS IS WHAT WILL MAKE SURE EVENTS ARE TRIGGERED
        changed
        ##################################################

        notify_observers widget_name, widget_event, data.to_deep_ostruct
      end
    end
  end
end
