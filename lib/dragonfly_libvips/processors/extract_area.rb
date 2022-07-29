require 'vips'
require 'dragonfly_libvips/processors'

module DragonflyLibvips
  module Processors
    class ExtractArea
      include DragonflyLibvips::Processors

      def call(content, *args, **options)
        wrap_process(content, *args, **options) do |img |
          x, y, width, height = args
          img = img.extract_area(x, y, width, height)
        end

        output_options.delete('Q') unless format.to_s =~ /jpg|jpeg/i
        output_options['format'] ||= format.to_s if format.to_s =~ /gif|bmp/i

        img = ::Vips::Image.new_from_file(content.path, **DragonflyLibvips.symbolize_keys(input_options))
        img = img.extract_area(x, y, width, height)

        content.update(
          img.write_to_buffer(".#{format}", **DragonflyLibvips.symbolize_keys(output_options)),
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
