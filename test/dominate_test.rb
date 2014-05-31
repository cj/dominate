require_relative 'helper'
require 'dominate'

setup do
  inline_html = <<-D
    <div>
      <div>
        <h1 data-scope='admin_only'>Admin</h1>
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
  instance = OpenStruct.new({
    current_user: OpenStruct.new({
      first_name: 'CJ',
      last_name: 'Lazell'
    })
  })

  OpenStruct.new({
    current_user: instance.current_user,
    dom: Dominate::HTML(inline_html, instance),
  })
end

scope 'dominate' do
  test 'render html' do |a|
    assert a.dom.html['test']
    assert a.dom.html.scan(/<a.*>/).length == 2
  end

  test 'binding data' do |a|
    a.dom.scope(:list).apply([
      { todo: 'get milk' },
      { todo: 'get cookies' },
      { todo: 'work out' },
    ])
    assert a.dom.html['test'] == nil
    assert a.dom.html.scan(/<a.*>/).length == 3
    assert a.dom.html['get milk']
    assert a.dom.html['get cookies']
  end

  test 'binding context' do |a|
    assert a.dom.html['John'] == nil
    assert a.dom.html['CJ']
  end

  test 'blocks' do |a|
    a.dom.scope(:admin_only).each do |node|
      unless a.current_user.admin
        node.remove
      end
    end
    assert a.dom.html['Admin'] == nil
  end

  test 'procs' do |a|
    data = [
      {todo: -> {
        current_user.admin ? 'do admin stuff' : 'do normal person stuff'}
      },
      {todo: ->(d) { d.length }
      }
    ]

    a.dom.scope(:list).apply(data)
    assert a.dom.html['do normal person stuff']
  end
end
