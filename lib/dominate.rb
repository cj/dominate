require "nokogiri"
require "tilt"
require "dominate/version"
require "dominate/inflectors"
require "dominate/scope"
require "dominate/dom"

module Dominate
  extend self

  attr_accessor :config, :reset_config

  def HTML html, instance = false, data = {}
    Dom.new html, instance, data
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
