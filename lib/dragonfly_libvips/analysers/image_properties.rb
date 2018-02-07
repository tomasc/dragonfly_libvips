require 'vips'

module DragonflyLibvips
  module Analysers
    class ImageProperties
      DPI = 300

      def call(content)
        input_options = {}
        input_options[:access] = :sequential
        input_options[:autorotate] = true if content.mime_type == 'image/jpeg'
        input_options[:dpi] = DPI if content.mime_type == 'application/pdf'

        img = ::Vips::Image.new_from_file(content.path, input_options)

        width, height = img.width, img.height
        xres, yres = img.xres, img.yres

        {
          'format' => content.ext.downcase,
          'width' => width,
          'height' => height,
          'xres' => xres,
          'yres' => yres
        }
      end
    end
  end
end
