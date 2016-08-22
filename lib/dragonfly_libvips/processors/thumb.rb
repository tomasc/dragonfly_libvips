module DragonflyLibvips
  module Processors
    class Thumb
      OPERATORS = '><'.freeze
      RESIZE_GEOMETRY = /\A\d*x\d*[#{OPERATORS}]?\z/ # e.g. '300x200>'

      def call(content, geometry, opts = {})
        image_properties = content.analyse(:image_properties)
        args = [args_for_geometry(geometry, image_properties), opts['args']].compact.join(' ')
        content.process!(:vipsthumbnail, args, opts)
      end

      def update_url(url_attributes, _geometry, opts = {})
        format = opts['format']
        url_attributes.ext = format if format
      end

      private

      def args_for_geometry(geometry, image_properties)
        case geometry
        when RESIZE_GEOMETRY then resize_args(geometry, image_properties)
        else raise ArgumentError, "Didn't recognise the geometry string #{geometry}"
        end
      end

      def resize_args(geometry, image_properties)
        res = Dimensions.call(geometry, image_properties['width'], image_properties['height'])
        "-s #{res.width.round}x#{res.height.round}"
      end
    end
  end
end
