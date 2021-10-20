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

      def call(content, geometry, options = {})

        wrap_process(content, **options) do |img, **input_options|

          dimensions = Dimensions.call(orig_w: img.width, orig_h: img.height, **Geometry.call(geometry))
          crop_content = !(dimensions.to_h.keys & CROP_KEYS).empty?

          if crop_content
            img.crop(dimensions.x, dimensions.y, dimensions.width, dimensions.height)
          else
            thumbnail_options = set_thumbnail_options(input_options,
                                                      dimensions,
                                                      output_cmyk: img.get('interpretation') == :cmyk,
                                                      input_is_jpeg: content.mime_type == 'image/jpeg')
            img.thumbnail_image(dimensions.width.ceil, **thumbnail_options)
          end
        end
      end
    end

    def set_thumbnail_options(input_options, dimensions, input_is_jpeg: false, output_cmyk: false)
      options = input_options.fetch('thumbnail_options', {})
      options[:height] = options.fetch('height', dimensions.height.ceil)

      if input_is_jpeg
        if Vips.at_least_libvips?(8, 8)
          options[:no_rotate] = input_options.fetch('no_rotate', false)
        else
          options[:auto_rotate] = input_options.fetch('autorotate', true)
        end
      end
      options[:import_profile] = CMYK_PROFILE_PATH if output_cmyk
      options[:size] ||= dimensions.resize
      options
    end
  end
end

