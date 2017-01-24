require 'dragonfly_libvips/dimensions'
require 'vips'

module DragonflyLibvips
  module Processors
    class Thumb
      OPERATORS = '><'.freeze
      RESIZE_GEOMETRY = /\A\d*x\d*[#{OPERATORS}]?\z/ # e.g. '300x200>'
      RESIZE_KEYS = %w(kernel).freeze

      def call(content, geometry, format: content.ext, input_options: {}, resize_options: {}, output_options: {})
        input_options[:access] ||= :sequential
        output_options[:profile] ||= EPROFILE_PATH

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

      def update_url(url_attributes, _, opts = {})
        format = opts['format']
        url_attributes.ext = format if format
      end
    end
  end
end
