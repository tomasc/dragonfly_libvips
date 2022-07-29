require 'vips'

module DragonflyLibvips
  module Processors

    def wrap_process(content, *args, **options, &block)

      raise DragonflyLibvips::UnsupportedFormat unless content.ext
      raise DragonflyLibvips::UnsupportedFormat unless SUPPORTED_FORMATS.include?(content.ext.downcase)

      options = DragonflyLibvips.stringify_keys(**options)
      format = options.fetch('format', content.ext)
      input_options = get_input_options(content.mime_type, **options)

      img = ::Vips::Image.new_from_file(content.path, **DragonflyLibvips.symbolize_keys(**input_options))

      img = yield img, **input_options

      output_options = get_output_options(format, input_options.fetch('profile', EPROFILE_PATH), **options)
      content.update(
        img.write_to_buffer(".#{format}", **DragonflyLibvips.symbolize_keys(**output_options)),
        'name' => "temp.#{format}",
        'format' => format
      )
      content.ext = format
    end

    def update_url(url_attributes, *_, **options)
      options = DragonflyLibvips.stringify_keys(**options)
      return unless format = options.fetch('format', nil)
      url_attributes.ext = format
    end

    private

      def get_input_options(mime_type, **options)
        input_options = options.fetch('input_options', {})
        input_options['autorotate'] = true if mime_type == 'image/jpeg' && input_options['autorotate'].nil?
        input_options
      end

      def get_output_options(format, input_profile, **options)
        output_options = options.fetch('output_options', {})

        output_options['profile'] = get_output_profile(format, output_options['profile'], input_profile)
        output_options.delete('profile') if output_options[:profile].nil?

        output_options.delete('Q') unless format.to_s =~ /jpg|jpeg/i
        output_options['format'] ||= format.to_s if format.to_s =~ /gif|bmp/i
        output_options['compression'] ||= get_compression_option(format.to_s) if format.to_s =~ /heif|avif/
        output_options
      end

      def get_compression_option(format)
        case format
          when 'heif'
            'hevc'
          when 'avif'
            'av1'
        end
      end

      def get_output_profile(format, output_profile, input_profile)
        FORMATS_WITHOUT_PROFILE_SUPPORT.include?(format) ? nil : output_profile || input_profile
      end
  end
end

