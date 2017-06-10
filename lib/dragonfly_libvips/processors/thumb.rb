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
        raise ArgumentError, "Didn't recognise the geometry string #{geometry}" unless geometry =~ RESIZE_GEOMETRY

        options = options.deep_stringify_keys

        vipsthumbnail_command = content.env.fetch(:vipsthumbnail_command, 'vipsthumbnail')
        format = options.fetch('format', nil)

        if input_options = options.fetch('input_options', nil)
          input_args = input_options.map{ |k,v| "#{k}=#{v}" }.join(',')
          input_args = "[#{input_args}]"
        end

        if output_options = options.fetch('output_options', nil)
          output_args = output_options.map{ |k,v| "#{k}=#{v}" }.join(',')
          output_args = "[#{output_args}]"
        end

        args = options.fetch('args', '')
        unless args.include?('eprofile')
          args = [args, "--eprofile=#{DragonflyLibvips::EPROFILE_PATH}"].compact.join(' ')
        end

        # vipsthumbnail does not correctly handle 'NNx' definition
        if geometry_incomplete?(geometry)
          img = ::Vips::Image.new_from_file(content.path)
          dimensions =  DragonflyLibvips::Dimensions.call(geometry, img.width, img.height)
          geometry = ["#{dimensions.width.to_i}x#{dimensions.height.to_i}", dimensions.modifier].reject(&:blank?).join
        end

        args = [args, "--size=#{geometry}"].compact.join(' ')

        content.shell_update ext: format do |old_path, new_path|
          "#{vipsthumbnail_command} #{old_path}#{input_args} -o #{new_path}#{output_args} #{args}"
        end

        if format
          content.meta['format'] = format.to_s
          content.ext = format
        end
      end

      def update_url(url_attributes, geometry, options = {})
        options = options.deep_stringify_keys

        if format = options.fetch('format', nil)
          url_attributes.ext = format
        end
      end

      private

      def geometry_incomplete?(geometry)
        w, h = geometry.scan(/\A(\d*)x(\d*)/).flatten.map(&:to_f)
        return true if w == 0
        return true if h == 0
      end
    end
  end
end
