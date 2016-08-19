module DragonflyLibvips
  module Processors
    class Vipsthumbnail
      def call(content, args = '', opts = {})
        vipsthumbnail_command = content.env[:vipsthumbnail_command] || 'vipsthumbnail'
        format = opts['format']

        content.shell_update ext: format do |old_path, new_path|
          "#{vipsthumbnail_command} #{old_path} -o #{new_path} #{args}"
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
