require "nokogiri"
require "nokogiri-styles"
require "tilt"
require "dominate/version"
require "dominate/inflectors"

module Dominate
  extend self

  autoload :Instance, "dominate/instance"
  autoload :HTML,     "dominate/html"
  autoload :Scope,    "dominate/scope"
  autoload :Dom,      "dominate/dom"
  autoload :Widget,   "dominate/widget"

  class NoFileFound < StandardError; end

  attr_accessor :config, :reset_config

  def setup
    yield config
  end

  def config
    @config || reset_config!
  end

  # Resets the configuration to the default (empty hash)
  def reset_config!
    @config = OpenStruct.new({
      view_path:   './views',
      layout:      'app',
      widget_path: './widgets',
      widget_url:  '/widgets',
      widgets:     {},
      parse_dom:   false
    })
  end

  def HTML html, instance = false, options = {}
    Dom.new html, instance, options
  end
end
