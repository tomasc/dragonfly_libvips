module DragonflyLibvips
  module Analysers
    class ImageProperties
      def call(content)
        vipsheader_command = content.env[:vipsheader_command] || 'vipsheader'

        details = content.shell_eval do |path|
          "#{vipsheader_command} #{path}"
        end

        _filename, dimensions, _bands, _interpretation, vips_loader = details.split(/\s*[:,]\s*/)
        width, height = dimensions.split(/\s+/).first.split('x')
        format = vips_loader.gsub(/\s*load\s*/, '').downcase

        {
          'format' => format.downcase,
          'width' => width.to_i,
          'height' => height.to_i
        }
      end
    end
  end
end
