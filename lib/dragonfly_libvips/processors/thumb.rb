require 'dragonfly_libvips/dimensions'
require 'dragonfly_libvips/geometry'
require 'dragonfly_libvips/processors'
require 'vips'

module DragonflyLibvips
  module Processors
    class Thumb
      include DragonflyLibvips::Processors
      DPI = 300
      CROP_KEYS = [:x, :y]

      def call(content, geometry,  options={})
        wrap_process(content, **options) do |img,  **input_options|

          dimensions = Dimensions.call(orig_w: img.width, orig_h: img.height, **Geometry.call(geometry))
          crop_content = !(dimensions.to_h.keys & CROP_KEYS).empty?

          thumbnail_options = options.fetch('thumbnail_options', {})
          if Vips.at_least_libvips?(8, 8)
            thumbnail_options['no_rotate'] = input_options.fetch('no_rotate', false) if content.mime_type == 'image/jpeg'
          else
            thumbnail_options['auto_rotate'] = input_options.fetch('autorotate', true) if content.mime_type == 'image/jpeg'
          end
          thumbnail_options['height'] = thumbnail_options.fetch('height', dimensions.height.ceil)
          thumbnail_options['import_profile'] = CMYK_PROFILE_PATH if img.get('interpretation') == :cmyk
          thumbnail_options['size'] ||= case geometry
            when />\z/ then :down # do_not_resize_if_image_smaller_than_requested
            when /<\z/ then :up # do_not_resize_if_image_larger_than_requested
            else :both
          end

          thumbnail_options = thumbnail_options.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v } # symbolize
          if crop_content
            img.extract_area(dimensions.x, dimensions.y, dimensions.width, dimensions.height)
          else
            img.thumbnail_image(dimensions.width.ceil, **DragonflyLibvips.symbolize_keys(**thumbnail_options))
          end
        end
      end
    end
  end
end
