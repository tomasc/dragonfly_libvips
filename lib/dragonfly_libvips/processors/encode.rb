require 'active_support/core_ext/hash'

module DragonflyLibvips
  module Processors
    class Encode
      def call(content, format, options = {})
        options = options.deep_stringify_keys
        options = { 'format' => format }.merge(options)
        content.process!(:vips, 'copy', '', options)
      end

      def update_url(url_attributes, format, options = {})
        url_attributes.ext = format.to_s
      end
    end
  end
end
