require_relative 'helper'

setup do
  mapper = Dominate::Mapper.new

  OpenStruct.new({
    mapper: mapper,
    html: <<-D
      <div>
        <span data-instance="test"></span>
        <span>moo</span>
      </div>
    D
  })
end

scope 'mapper' do
  test 'on' do |a|
    a.mapper.on :span, attributes: 'data-instance' do |e|
      ap '==========='
      ap e
      ap '==========='
    end

    a.mapper.parse a.html
  end
end
