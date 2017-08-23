require 'active_support/core_ext/hash'
require 'dragonfly_libvips/dimensions'
require 'vips'

module DragonflyLibvips
  module Processors
    class Thumb
      OPERATORS = '><'.freeze
      RESIZE_GEOMETRY = /\A\d*x\d*[#{OPERATORS}]?\z/ # e.g. '300x200>'
      RESIZE_KEYS = %w(kernel).freeze

      def call(content, geometry, options = {})
        options = options.deep_stringify_keys

        format = options.fetch('format', content.ext)

        input_options = options.fetch('input_options', {})
        resize_options = options.fetch('resize_options', {})
        output_options = options.fetch('output_options', {})

        input_options['access'] ||= 'sequential'
        if content.mime_type == 'image/jpeg'
          input_options['autorotate'] = true unless input_options.has_key?('autorotate')
        end
        output_options['profile'] ||= DragonflyLibvips::EPROFILE_PATH

        img = ::Vips::Image.new_from_file(content.path, input_options)

        dimensions = case geometry
        when RESIZE_GEOMETRY then DragonflyLibvips::Dimensions.call(geometry, img.width, img.height)
                     else raise ArgumentError, "Didn't recognise the geometry string #{geometry}"
        end

        if dimensions.scale != 1
          img = img.resize(dimensions.scale, resize_options)
        end

        content.update(img.write_to_buffer(".#{format}", output_options), 'format' => format)
        content.ext = format
      end

      def update_url(url_attributes, _, options = {})
        options = options.deep_stringify_keys

        if format = options.fetch('format', nil)
          url_attributes.ext = format
        end
      end
    end
  end
end
