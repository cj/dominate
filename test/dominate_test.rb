require_relative 'helper'
require 'dominate'

setup do
  OpenStruct.new({
    current_user: OpenStruct.new({
      first_name: 'CJ',
      last_name: 'Lazell'
    }),
    inline_html: <<-D
      <div>
        <div>
          <span>current_user:
            <span data-instance="current_user.first_name">John</span>
            <span data-instance="current_user.last_name">Doe</span>
          </span>
        </div>
        <ul data-scope="list">
          <li>
            <a href="#" data-prop="todo">test</a>
          </li>
          <li>
            <a href="#" data-prop="todo">testing</a>
          </li>
          <li>
            <ul data-scope="list-nested">
              <li data-prop="todo"></li>
            </ul>
          </li>
        </ul>
      </div>
    D
  })
end

scope 'dominate' do
  test 'render html' do |a|
    dom = Dominate::HTML a.inline_html
    assert dom.html['test']
    assert dom.html.scan(/<a.*>/).length == 2
  end

  test 'binding data' do |a|
    dom = Dominate::HTML a.inline_html
    dom.scope(:list).apply([
      { todo: 'get milk' },
      { todo: 'get cookies' },
      { todo: 'work out' },
    ])
    assert dom.html['test'] == nil
    assert dom.html.scan(/<a.*>/).length == 3
    assert dom.html['get milk']
    assert dom.html['get cookies']
  end

  test 'binding context' do |a|
    dom = Dominate::HTML a.inline_html, a
    assert dom.html['John'] == nil
    assert dom.html['CJ']
  end
end
