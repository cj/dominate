require_relative 'helper'

setup do
  mapper = Dominate::Mapper.new

  OpenStruct.new({
    mapper: mapper,
    html: <<-D
      <div>
        <span data-instance="test"></span>
      </div>
    D
  })
end

scope 'mapper' do
  test 'on' do |a|
    a.mapper.on attributes: 'data-instance' do |e|
      ap '==========='
      ap e
      ap '==========='
    end

    a.mapper.on attributes: 'data-empty' do |e|
      ap '==========='
      ap e
      ap '==========='
    end

    a.mapper.on :span, attributes: 'data-empty' do |e|
      ap '==========='
      ap 'this should not show'
      ap '==========='
    end

    a.mapper.on :span do |e|
      ap '==========='
      ap 'this should should show'
      ap '==========='
    end

    a.mapper.parse a.html
  end
end
