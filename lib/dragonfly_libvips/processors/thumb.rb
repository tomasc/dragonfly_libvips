module DragonflyLibvips
  module Processors
    class Thumb
      OPERATORS = '><'.freeze
      RESIZE_GEOMETRY = /\A\d*x\d*[#{OPERATORS}]?\z/ # e.g. '300x200>'

      def call(content, geometry, opts = {})
        image_properties = content.analyse(:image_properties)
        content.process!(:vipsthumbnail, args_for_geometry(geometry, image_properties), opts)
      end

      def update_url(url_attributes, _geometry, opts = {})
        format = opts['format']
        url_attributes.ext = format if format
      end

      def args_for_geometry(geometry, image_properties)
        case geometry
        when RESIZE_GEOMETRY then resize_args(geometry, image_properties)
        else raise ArgumentError, "Didn't recognise the geometry string #{geometry}"
        end
      end

      private

      def resize_args(geometry, image_properties)
        w = image_properties['width']
        h = image_properties['height']
        ratio = w.to_f / h.to_f
        is_landscape = ratio > 1.0

        width, height = geometry.scan(/\A(\d*)x(\d*)/).flatten.map(&:to_i)

        case geometry
        when /\Ax\d+[#{OPERATORS}]?/
          width = is_landscape ? (ratio * height).round : height
        when /\A\d+x[#{OPERATORS}]?\z/
          height = is_landscape ? width : (width / ratio).round
        end

        case geometry
        when />\z/
          width, height = w, h if width >= w || height >= h
        when /<\z/
          width, height = w, h if width <= w && height <= h
        end

        dimensions = "#{width}x#{height}"
        "-s #{dimensions}"
      end
    end
  end
end
