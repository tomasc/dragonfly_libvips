require 'active_support/core_ext/hash'

module DragonflyLibvips
  module Processors
    class Rotate
      def call(content, rotate, options = {})
        options = options.deep_stringify_keys

        format = options.fetch('format', content.ext)

        input_options = options.fetch('input_options', {})
        output_options = options.fetch('output_options', {})

        input_options['access'] ||= 'sequential'
        output_options['profile'] ||= DragonflyLibvips::EPROFILE_PATH

        puts "pid = #{Process.pid}"
        require 'vips'
        ::Vips::set_debug TRUE
        img = ::Vips::Image.new_from_file(content.path, input_options)

        img = img.rot("d#{rotate}")

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
