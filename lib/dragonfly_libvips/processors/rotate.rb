require 'vips'

module DragonflyLibvips
  module Processors
    class Rotate
      def call(content, rotate, options = {})
        format = options.fetch('format', content.ext)

        input_options = options.fetch('input_options', {})
        output_options = options.fetch('output_options', {})

        input_options['access'] ||= 'sequential'
        output_options['profile'] ||= DragonflyLibvips::EPROFILE_PATH

        img = ::Vips::Image.new_from_file(content.path, input_options)

        img = img.rot("d#{rotate}")

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
