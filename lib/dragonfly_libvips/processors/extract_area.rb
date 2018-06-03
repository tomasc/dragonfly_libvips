module DragonflyLibvips
  module Processors
    class ExtractArea
      def call(content, x, y, width, height, options = {})
        raise UnsupportedFormat unless SUPPORTED_FORMATS.include?(content.ext)

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

        img = img.extract_area(x, y, width, height)

        content.update(
          img.write_to_buffer(".#{format}", output_options),
          'name' => "temp.#{format}",
          'format' => format
        )
        content.ext = format
      end

      def update_url(url_attributes, _, _, _, _, options = {})
        options = options.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v } # stringify keys
        return unless format = options.fetch('format', nil)
        url_attributes.ext = format
      end
    end
  end
end
