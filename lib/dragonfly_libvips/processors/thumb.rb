require 'active_support/core_ext/hash'
require 'dragonfly/utils'
require 'dragonfly_libvips/dimensions'
require 'vips'

module DragonflyLibvips
  module Processors
    class Thumb
      OPERATORS = '><'.freeze
      RESIZE_GEOMETRY = /\A\d*x\d*[#{OPERATORS}]?\z/ # e.g. '300x200>'

      def call(content, geometry, options = {})
        options = options.deep_stringify_keys

        format = options.fetch('format', content.ext)

        input_options = options.fetch('input_options', {})
        thumbnail_options = options.fetch('thumbnail_options', {})
        output_options = options.fetch('output_options', {})

        input_options['access'] ||= 'sequential'
        output_options['profile'] ||= DragonflyLibvips::EPROFILE_PATH

        img = ::Vips::Image.new_from_file(content.path, input_options)

        dimensions = case geometry
        when RESIZE_GEOMETRY then DragonflyLibvips::Dimensions.call(geometry, img.width, img.height)
        else raise ArgumentError, "Didn't recognise the geometry string #{geometry}"
        end

        thumbnail_options['height'] ||= dimensions.height.ceil

        thumbnail_options['size'] ||= case geometry
        when />\z/ then Vips::Size::DOWN # do_not_resize_if_image_smaller_than_requested
        when /<\z/ then Vips::Size::UP # do_not_resize_if_image_larger_than_requested
        else Vips::Size::BOTH
        end

        thumb = ::Vips::Image.thumbnail(content.path, dimensions.width.ceil, thumbnail_options)

        content.update(thumb.write_to_buffer(".#{format}", output_options), 'format' => format)
        content.ext = format
      end

      def update_url(url_attributes, _, options = {})
        options = options.deep_stringify_keys

        if format = options.fetch('format', nil)
          url_attributes.ext = format
        end
      end
    end
  end
end
