require 'vips'
require 'dragonfly_libvips/processors'

module DragonflyLibvips
  module Processors
    class Rotate
      include DragonflyLibvips::Processors

      def call(content, degrees, **options)
        wrap_process(content, degrees, **options) do |img|
          img = img.rot("d#{degrees}")
        end
      end
    end
  end
end
