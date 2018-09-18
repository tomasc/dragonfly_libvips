module DragonflyLibvips
  module Processors
    class Rotate
      def call(content, rotate, options = {})
        raise UnsupportedFormat unless content.ext
        raise UnsupportedFormat unless SUPPORTED_FORMATS.include?(content.ext.downcase)

        options = options.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v } # stringify keys
        format = options.fetch('format', content.ext)

        input_options = options.fetch('input_options', {})
        output_options = options.fetch('output_options', {})

        # input_options['access'] ||= 'sequential'
        if content.mime_type == 'image/jpeg'
          input_options['autorotate'] = true unless input_options.has_key?('autorotate')
        end
        output_options['profile'] ||= EPROFILE_PATH

        require 'vips'
        img = ::Vips::Image.new_from_file(content.path, input_options)

        img = img.rot("d#{rotate}")

        content.update(
          img.write_to_buffer(".#{format}", output_options),
          'name' => "temp.#{format}",
          'format' => format
        )
        content.ext = format
      end

      def update_url(url_attributes, _, options = {})
        options = options.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v } # stringify keys
        return unless format = options.fetch('format', nil)
        url_attributes.ext = format
      end
    end
  end
end
