module DragonflyLibvips
  module Analysers
    class ImageProperties
      def call(content)
        require 'vips'

        input_options = {}
        input_options[:access] = :sequential
        input_options[:autorotate] = true if content.mime_type == 'image/jpeg'

        img = ::Vips::Image.new_from_file(content.path, input_options)

        width, height = img.width, img.height
        xres, yres = img.xres, img.yres

        {
          'format' => content.ext,
          'width' => width,
          'height' => height,
          'xres' => xres,
          'yres' => yres
        }
      end
    end
  end
end
