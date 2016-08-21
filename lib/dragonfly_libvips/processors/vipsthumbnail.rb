module DragonflyLibvips
  module Processors
    class Vipsthumbnail
      def call(content, args = '', opts = {})
        vipsthumbnail_command = content.env[:vipsthumbnail_command] || 'vipsthumbnail'
        format = opts['format']

        if input_args = opts['input_args']
          input_args = "[#{input_args}]"
        end

        if output_args = opts['output_args']
          output_args = "[#{output_args}]"
        end

        # args = [args, "--eprofile=#{EPROFILE_PATH}"].compact.join(' ') unless args.include?('eprofile')

        content.shell_update ext: format do |old_path, new_path|
          "#{vipsthumbnail_command} #{old_path}#{input_args} -o #{new_path}#{output_args} #{args}"
        end

        if format
          content.meta['format'] = format.to_s
          content.ext = format
        end
      end

      def update_url(attrs,  _args = '', opts = {})
        format = opts['format']
        attrs.ext = format if format
      end
    end
  end
end
