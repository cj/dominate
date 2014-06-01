require_relative 'helper'
require 'dominate'
require 'slim'

setup do
  Dominate.reset_config!
  Dominate.setup do |c|
    c.view_path = './test/dummy'
  end

  inline_html = File.read './test/dummy/index.html'

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
  test 'html' do |a|
    assert a.dom.html['test']
    assert a.dom.html.scan(/<a.*>/).length == 2
  end

  test 'data' do |a|
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

  test 'context' do |a|
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

  test 'partial' do |a|
    data = {
      company: {
        name: 'Test Company'
      }
    }

    a.dom.scope(:footer).apply data
    assert a.dom.html['Test Company']
  end
end
