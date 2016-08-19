require 'dragonfly/shell'
require 'dragonfly_libvips/analysers/image_properties'
require 'dragonfly_libvips/processors/encode'
require 'dragonfly_libvips/processors/thumb'
require 'dragonfly_libvips/processors/vips'
require 'dragonfly_libvips/processors/vipsthumbnail'

module DragonflyLibvips
  class Plugin
    def call(app, opts = {})
      # ENV
      app.env[:vips_command] = opts[:vips_command] || 'vips'
      app.env[:vipsheader_command] = opts[:vipsheader_command] || 'vipsheader'
      app.env[:vipsthumbnail_command] = opts[:vipsthumbnail_command] || 'vipsthumbnail'

      # Analysers
      app.add_analyser :image_properties, DragonflyLibvips::Analysers::ImageProperties.new

      app.add_analyser :width do |content|
        content.analyse(:image_properties)['width']
      end

      app.add_analyser :height do |content|
        content.analyse(:image_properties)['height']
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
        rescue Dragonfly::Shell::CommandFailed
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
      app.add_processor :vips, Processors::Vips.new
      app.add_processor :vipsthumbnail, Processors::Vipsthumbnail.new
      app.add_processor :rotate do |content, amount|
        content.process!(:vips, 'rot', "d#{amount}")
      end

      # Extra methods
      app.define :vipsheader do |*args|
        cli_args = args.first # because ruby 1.8.7 can't deal with default args in blocks
        shell_eval do |path|
          "#{app.env[:vipsheader_command]} #{cli_args} #{path}"
        end
      end
    end
  end
end

Dragonfly::App.register_plugin(:libvips) { DragonflyLibvips::Plugin.new }
