require 'active_support/core_ext/hash'

module DragonflyLibvips
  module Processors
    class Encode
      def call(content, format, options = {})
        options = options.deep_stringify_keys

        input_options = options.fetch('input_options', {})
        output_options = options.fetch('output_options', {})

        input_options['access'] ||= 'sequential'
        output_options['profile'] ||= DragonflyLibvips::EPROFILE_PATH

        puts "pid = #{Process.pid}"
        require 'vips'
        ::Vips::set_debug TRUE
        img = ::Vips::Image.new_from_file(content.path, input_options)

        content.update(img.write_to_buffer(".#{format}", output_options), 'format' => format)
        content.ext = format
      end

      def update_url(url_attributes, format, options = {})
        url_attributes.ext = format.to_s
      end
    end
  end
end
