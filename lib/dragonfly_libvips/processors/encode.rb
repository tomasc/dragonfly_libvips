module DragonflyLibvips
  module Processors
    class Encode
      FORMATS_WITHOUT_PROFILE_SUPPORT = %w[dz webp hdr]

      def call(content, format, options = {})
        raise UnsupportedFormat unless SUPPORTED_FORMATS.include?(content.ext)

        format = format.to_s

        raise UnsupportedOutputFormat unless SUPPORTED_OUTPUT_FORMATS.include?(format)

        if content.mime_type == Rack::Mime.mime_type(".#{format}")
          content.ext ||= format
          content.meta['format'] = format
          return
        end

        options = options.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v } # stringify keys

        input_options = options.fetch('input_options', {})
        output_options = options.fetch('output_options', {})

        input_options['access'] ||= 'sequential'
        if content.mime_type == 'image/jpeg'
          input_options['autorotate'] = true unless input_options.has_key?('autorotate')
        end

        output_options['profile'] ||= EPROFILE_PATH
        output_options.delete('profile') if FORMATS_WITHOUT_PROFILE_SUPPORT.include?(format)

        require 'vips'
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
