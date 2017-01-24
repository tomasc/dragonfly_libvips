require 'vips'

module DragonflyLibvips
  module Analysers
    class ImageProperties
      def call(content)
        img = ::Vips::Image.new_from_file(content.path, access: :sequential)

        {
          'format' => content.ext,
          'width' => img.width,
          'height' => img.height,
          'xres' => img.xres,
          'yres' => img.yres,
        }
      end
    end
  end
end
