require 'active_support/core_ext/hash'
require 'dragonfly_libvips/dimensions'
require 'vips'

module DragonflyLibvips
  module Processors
    class Thumb
      OPERATORS = '><'.freeze
      RESIZE_GEOMETRY = /\A\d*x\d*[#{OPERATORS}]?\z/ # e.g. '300x200>'
      DPI = 300

      def call(content, geometry, options = {})
        options = options.deep_symbolize_keys

        filename = content.path
        format = options.fetch(:format, content.ext)

        input_options = options.fetch(:input_options, {})
        input_options[:access] = input_options.fetch(:access, 'sequential')
        input_options[:autorotate] = input_options.fetch(:autorotate, true) if content.mime_type == 'image/jpeg'

        if content.mime_type == 'application/pdf'
          input_options[:dpi] = input_options.fetch(:dpi, DPI) if content.mime_type == 'application/pdf'
          input_options[:page] = input_options.fetch(:page, 0) if content.mime_type == 'application/pdf'
        else
          input_options.delete(:page)
          input_options.delete(:dpi)
        end

        output_options = options.fetch(:output_options, {})
        output_options[:profile] = input_options.fetch(:profile, DragonflyLibvips::EPROFILE_PATH)

        img = ::Vips::Image.new_from_file(filename, input_options)

        dimensions = case geometry
                     when RESIZE_GEOMETRY then DragonflyLibvips::Dimensions.call(geometry, img.width, img.height)
                     else raise ArgumentError, "Didn't recognise the geometry string: #{geometry}"
        end

        thumbnail_options = options.fetch(:thumbnail_options, {})
        thumbnail_options[:auto_rotate] = input_options.fetch(:autorotate, true) if content.mime_type == 'image/jpeg'
        thumbnail_options[:height] = thumbnail_options.fetch(:height, dimensions.height.ceil)
        thumbnail_options[:size] ||= case geometry
                                     when />\z/ then :down # do_not_resize_if_image_smaller_than_requested
                                     when /<\z/ then :up # do_not_resize_if_image_larger_than_requested
                                     else :both
        end

        filename += "[page=#{input_options[:page]}]" if content.mime_type == 'application/pdf'
        thumb = ::Vips::Image.thumbnail(filename, dimensions.width.ceil, thumbnail_options)

        content.update(thumb.write_to_buffer(".#{format}", output_options), 'format' => format)
        content.ext = format
      end

      def update_url(url_attributes, _, options = {})
        options = options.deep_symbolize_keys

        if format = options.fetch(:format, nil)
          url_attributes.ext = format
        end
      end
    end
  end
end
