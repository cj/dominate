require_relative 'helper'
require 'cuba'

setup do
  Dominate.reset_config!
  Dominate.setup do |c|
    c.widget_path = './test/dummy/widgets'
    c.widget_url  = '/widgets'
    c.widgets = {
      some_widget: 'SomeWidget'
    }
  end

  Cuba.reset!
  Cuba.plugin Dominate::Widget::Helper
  Cuba.use Dominate::Widget::Middleware
  Cuba.define do
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

    assert resp.join.scan('Hello, World!').length == 2
  end
end
