require 'vips'

module DragonflyLibvips
  module Processors
    class Rotate
      def call(content, rotate, options = {})
        raise UnsupportedFormat unless content.ext
        raise UnsupportedFormat unless SUPPORTED_FORMATS.include?(content.ext.downcase)

        options = DragonflyLibvips.stringify_keys(options)
        format = options.fetch('format', content.ext)

        input_options = options.fetch('input_options', {})

        # input_options['access'] ||= 'sequential'
        if content.mime_type == 'image/jpeg'
          input_options['autorotate'] = true unless input_options.has_key?('autorotate')
        end

        output_options = options.fetch('output_options', {})
        if FORMATS_WITHOUT_PROFILE_SUPPORT.include?(format)
          output_options.delete('profile')
        else
          output_options['profile'] ||= input_options.fetch('profile', EPROFILE_PATH)
        end
        output_options.delete('Q') unless format.to_s =~ /jpg|jpeg/i
        output_options['format'] ||= format.to_s if format.to_s =~ /gif|bmp/i

        img = ::Vips::Image.new_from_file(content.path, **DragonflyLibvips.symbolize_keys(input_options))
        img = img.rot("d#{rotate}")

        content.update(
          img.write_to_buffer(".#{format}", **DragonflyLibvips.symbolize_keys(output_options)),
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
