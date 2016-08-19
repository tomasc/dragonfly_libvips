module DragonflyLibvips
  module Processors
    class Encode
      def call(content, format, output_args = '')
        opts = { 'format' => format, 'output_args' => output_args }
        content.process!(:vips, 'copy', '', opts)
      end

      def update_url(attrs, format, _args = '')
        attrs.ext = format.to_s
      end
    end
  end
end
