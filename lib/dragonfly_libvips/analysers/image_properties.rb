require 'vips'

module DragonflyLibvips
  module Analysers
    class ImageProperties
      DPI = 300

      def call(content)
        return {} unless SUPPORTED_FORMATS.include?(content.ext)

        input_options = {}
        input_options['access'] = 'sequential'
        input_options['autorotate'] = true if content.mime_type == 'image/jpeg'
        input_options['dpi'] = DPI if content.mime_type == 'application/pdf'

        img = ::Vips::Image.new_from_file(content.path, input_options)

        width = img.width
        height = img.height
        xres = img.xres
        yres = img.yres

        res = {
          'format' => content.ext.to_s,
          'width' => width,
          'height' => height,
          'xres' => xres,
          'yres' => yres
        }
        res['progressive'] = img.get('jpeg-multiscan') != 0 if content.mime_type == 'image/jpeg'
        res
      end
    end
  end
end
