require 'vips'

module DragonflyLibvips
  module Processors
    class Rotate
      def call(content, rotate, format: content.ext, input_options: {}, resize_options: {}, output_options: {})
        input_options[:access] ||= :sequential

        img = ::Vips::Image.new_from_file(content.path, input_options)

        img = img.rot("d#{rotate}")

        content.update(img.write_to_buffer(".#{format}", output_options), { 'format' => format })
        content.ext = format
      end

      def update_url(url_attributes, _, opts = {})
        format = opts['format']
        url_attributes.ext = format if format
      end
    end
  end
end
