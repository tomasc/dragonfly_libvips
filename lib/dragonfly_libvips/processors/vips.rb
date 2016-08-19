module DragonflyLibvips
  module Processors
    class Vips
      def call(content, commands, args = '', opts = {})
        vips_command = content.env[:vips_command] || 'vips'
        format = opts['format']

        if input_args = opts['input_args']
          input_args = "[#{input_args}]"
        end

        if output_args = opts['output_args']
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

      def update_url(attrs, _commands, _args = '', opts = {})
        format = opts['format']
        attrs.ext = format if format
      end
    end
  end
end
