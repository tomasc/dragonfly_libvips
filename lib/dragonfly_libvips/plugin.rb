require 'dragonfly_libvips/analysers/image_properties'
require 'dragonfly_libvips/processors/encode'
require 'dragonfly_libvips/processors/rotate'
require 'dragonfly_libvips/processors/thumb'
require 'vips'

module DragonflyLibvips
  class Plugin
    def call(app, _opts = {})
      # Analysers
      app.add_analyser :image_properties, DragonflyLibvips::Analysers::ImageProperties.new

      app.add_analyser :width do |content|
        content.analyse(:image_properties)['width']
      end

      app.add_analyser :height do |content|
        content.analyse(:image_properties)['height']
      end

      app.add_analyser :xres do |content|
        content.analyse(:image_properties)['xres']
      end

      app.add_analyser :yres do |content|
        content.analyse(:image_properties)['yres']
      end

      app.add_analyser :format do |content|
        content.analyse(:image_properties)['format']
      end

      app.add_analyser :aspect_ratio do |content|
        attrs = content.analyse(:image_properties)
        attrs['width'].to_f / attrs['height']
      end

      app.add_analyser :portrait do |content|
        attrs = content.analyse(:image_properties)
        attrs['width'] <= attrs['height']
      end

      app.add_analyser :landscape do |content|
        !content.analyse(:portrait)
      end

      app.add_analyser :image do |content|
        begin
          content.analyse(:image_properties).key?('format')
        rescue ::Vips::Error
          false
        end
      end

      # Aliases
      app.define(:portrait?) { portrait }
      app.define(:landscape?) { landscape }
      app.define(:image?) { image }

      # Processors
      app.add_processor :encode, Processors::Encode.new
      app.add_processor :thumb, Processors::Thumb.new
      app.add_processor :rotate, Processors::Rotate.new
    end
  end
end

Dragonfly::App.register_plugin(:libvips) { DragonflyLibvips::Plugin.new }
