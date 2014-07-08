require_relative 'helper'

setup do
  mapper = Dominate::Mapper.new

  OpenStruct.new({
    mapper: mapper,
    html: <<-D
      <div>
        <span data-instance="test">cow</span>
        <span>moo</span>
      </div>
    D
  })
end

scope 'mapper' do
  test 'on' do |a|
    a.mapper.on :span, attributes: 'data-instance' do |e|
      e.text = 'changed'
    end

    a.mapper.parse a.html
  end
end
