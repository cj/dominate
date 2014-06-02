require "nokogiri"
require "nokogiri-styles"
require "tilt"
require "dominate/version"
require "dominate/inflectors"
require "dominate/html"
require "dominate/scope"
require "dominate/dom"

module Dominate
  extend self

  attr_accessor :config, :reset_config

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

  def HTML html, instance = false, options = {}
    Dom.new html, instance, options
  end
end
