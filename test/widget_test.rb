require_relative 'helper'
require 'cuba'

setup do
  Dominate.reset_config!
  Dominate.setup do |c|
    c.widget_path = './test/dummy/widgets'
    c.widget_url  = '/widgets'
    c.widgets = {
      some_widget:  'SomeWidget',
      other_widget: 'OtherWidget'
    }
  end

  Cuba.reset!
  # Cuba.use Dominate::Widget::Middleware
  Cuba.plugin Dominate::Widget::Helper
  Cuba.define do

    on "widgets" do
      @dominate_event ||= Dominate::Widget::Event.new

      widget_name, widget_event, event = Dominate::Widget.load_all self, @dominate_event, req, res

      event.trigger widget_name, widget_event, req.params
      # res.write "$('head > meta[name=csrf-token]').attr('content', '#{csrf_token}');"
      res.write '$(document).trigger("page:change");'
    end

    on "test" do
      res.write render_widget :some_widget
    end
  end
end

scope 'dominate widget' do
  test 'render_widget' do |a|
    _, _, resp = Cuba.call({
      'PATH_INFO'   => '/test',
      'SCRIPT_NAME'   => '/test',
      'REQUEST_METHOD' => 'GET',
      'rack.input'     => {}
    })
    body = resp.join

    assert body.scan('Hello, World!').length == 2
    assert body['some-widget-display']
  end

  test 'event' do
    _, _, resp = Cuba.call({
      'PATH_INFO'   => '/widgets',
      'SCRIPT_NAME'   => '/widgets',
      'REQUEST_METHOD' => 'GET',
      'rack.input'     => {},
      'QUERY_STRING'   => 'widget_name=some_widget&widget_event=test'
    })
    body = resp.join

    assert body['Hello, World!']
    assert body['moo']
    assert body['cow']
    assert body['some-widget-display']
    assert body['some-widget-test']
  end
end
