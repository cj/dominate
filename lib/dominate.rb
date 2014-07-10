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
  autoload :Assets,   "dominate/assets"

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
      parse_dom:   false,
      layout:      'app',
      layout_path: './views/layouts',
      view_path:   './views',
      widget_path: './widgets',
      widget_url:  '/widgets',
      widgets:     {},
      assets: OpenStruct.new({
        js: {},
        css: {}
      }),
      asset_url:        '/assets',
      asset_path:       './assets',
      asset_js_folder:  'js',
      asset_css_folder: 'css',
      assets_compiled:  false
    })
  end

  def HTML html, instance = false, options = {}
    Dom.new html, instance, options
  end
end
