require "nokogiri"
require "dominate/version"
require "dominate/inflectors"
require "dominate/scope"
require "dominate/dom"

module Dominate
  extend self

  attr_accessor :config, :reset_config, :load_all

  def HTML html, data = {}
    Dom.new html, data
  end

  def setup
    yield config
  end

  def config
    @config || reset_config!
  end

  # Resets the configuration to the default (empty hash)
  def reset_config!
    @config = OpenStruct.new
  end
end
