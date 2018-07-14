require 'dragonfly_libvips/analysers/image_properties'
require 'dragonfly_libvips/processors/encode'
require 'dragonfly_libvips/processors/extract_area'
require 'dragonfly_libvips/processors/rotate'
require 'dragonfly_libvips/processors/thumb'

module DragonflyLibvips
  class Plugin
    def call(app, _opts = {})
      # Analysers
      app.add_analyser :image_properties, DragonflyLibvips::Analysers::ImageProperties.new

      %w[ width
          height
          xres
          yres
          format
      ].each do |name|
        app.add_analyser(name) { |c| c.analyse(:image_properties)[name] }
      end

      app.add_analyser(:aspect_ratio) { |c| c.analyse(:width).to_f / c.analyse(:height).to_f }
      app.add_analyser(:portrait) { |c| c.analyse(:aspect_ratio) < 1.0 }
      app.add_analyser(:landscape) { |c| !c.analyse(:portrait) }

      app.add_analyser(:image) do |c|
        begin
          c.analyse(:image_properties).key?('format')
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
      app.add_processor :extract_area, Processors::ExtractArea.new
      app.add_processor :thumb, Processors::Thumb.new
      app.add_processor :rotate, Processors::Rotate.new
    end
  end
end

Dragonfly::App.register_plugin(:libvips) { DragonflyLibvips::Plugin.new }
