require 'dragonfly_libvips/dimensions'
require 'dragonfly_libvips/geometry'
require 'dragonfly_libvips/processors'
require 'vips'
require "active_support/core_ext/hash/except"

module DragonflyLibvips
  module Processors
    class Thumb
      include DragonflyLibvips::Processors
      DPI = 300
      CROP_KEYS = [:x, :y]
      SHRINK_KEYS = [:x_scale, :y_scale]

      def call(content, geometry, options = {})

        wrap_process(content, **options) do |img, **input_options|

          dimensions = Dimensions.call(orig_w: img.width, orig_h: img.height, **Geometry.call(geometry))
          process = :shrink unless (dimensions.to_h.keys & SHRINK_KEYS).empty?
          process = :crop unless (dimensions.to_h.keys & CROP_KEYS).empty?
          process = process ||= :thumbnail_image

          thumbnail_options = set_thumbnail_options(
            input_options, dimensions,
            cmyk:  img.get('interpretation') == :cmyk,
            jpeg:  content.mime_type == 'image/jpeg'
          )
          case process
            when :shrink
              thumbnail_options.except!(:height, :size)
              thumbnail_options[:xshrink] = dimensions.x_scale
              thumbnail_options[:yshrink] = dimensions.y_scale
              img.shrink(dimensions.x_scale, dimensions.y_scale, **thumbnail_options)
            when :crop
              thumbnail_options.except!(:height, :size)
              img.crop(dimensions.x, dimensions.y, dimensions.width, dimensions.height, **thumbnail_options)
            else
              thumbnail_options[:crop] = :centre if geometry.match( /\^/)
              img.thumbnail_image(dimensions.width.ceil, **thumbnail_options)
          end
        end
      end
    end

    def set_thumbnail_options(input_options, dimensions, jpeg: false, cmyk: false)
      options = input_options.fetch('thumbnail_options', {})
      options[:height] = options.fetch('height', dimensions.height.ceil)  if dimensions.height

      if jpeg
        if Vips.at_least_libvips?(8, 8)
          options[:no_rotate] = input_options.fetch('no_rotate', false)
        else
          options[:auto_rotate] = input_options.fetch('autorotate', true)
        end
      end
      options[:import_profile] = CMYK_PROFILE_PATH if cmyk
      options[:size] ||= dimensions.resize
      options
    end
  end
end

