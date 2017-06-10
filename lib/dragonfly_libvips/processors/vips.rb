module DragonflyLibvips
  module Processors
    class Vips
      def call(content, commands, args = '', options = {})
        options = options.deep_stringify_keys

        vips_command = content.env.fetch(:vips_command, 'vips')
        format = options.fetch('format', 'jpg')

        if input_options = options.fetch('input_options', nil)
          input_args = input_options.map{ |k,v| "#{k}=#{v}" }.join(',')
          input_args = "[#{input_args}]"
        end

        if output_options = options.fetch('output_options', nil)
          output_args = output_options.map{ |k,v| "#{k}=#{v}" }.join(',')
          output_args = "[#{output_args}]"
        end

        content.shell_update ext: format do |old_path, new_path|
          "#{vips_command} #{commands} #{old_path}#{input_args} #{new_path}#{output_args} #{args}"
        end

        if format
          content.meta['format'] = format.to_s
          content.ext = format
        end
      end

      def update_url(url_attributes, commands, args = '', options = {})
        format = options.fetch('format', 'jpg')
        url_attributes.ext = format.to_s
      end
    end
  end
end
