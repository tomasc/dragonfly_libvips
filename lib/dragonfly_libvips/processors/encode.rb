require 'vips'

module DragonflyLibvips
  module Processors
    class Encode
      def call(content, format, input_options: {}, output_options: {})
        input_options[:access] ||= :sequential
        output_options[:profile] ||= DragonflyLibvips::EPROFILE_PATH

        img = ::Vips::Image.new_from_file(content.path, input_options)

        content.update(img.write_to_buffer(".#{format}", output_options), 'format' => format)
        content.ext = format
      end

      def update_url(attrs, format, _args = '')
        attrs.ext = format.to_s
      end
    end
  end
end
