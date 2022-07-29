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
      end
    end
  end
end
