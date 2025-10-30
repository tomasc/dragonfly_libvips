# frozen_string_literal: true

require "vips"

module DragonflyLibvips
  module Processors
    class Encode
      def call(content, format, options = {})
        raise UnsupportedFormat unless content.ext
        raise UnsupportedFormat unless SUPPORTED_FORMATS.include?(content.ext.downcase)

        format = format.to_s
        format = "tif" if format == "tiff"
        format = "jpg" if format == "jpeg"

        raise UnsupportedOutputFormat unless SUPPORTED_OUTPUT_FORMATS.include?(format.downcase)

        if content.mime_type == Rack::Mime.mime_type(".#{format}")
          content.ext ||= format
          content.meta["format"] = format
          return
        end

        options = DragonflyLibvips.stringify_keys(options)

        input_options = options.fetch("input_options", {})
        input_options["access"] ||= "sequential"
        if content.mime_type == "image/jpeg"
          input_options["autorotate"] = true unless input_options.key?("autorotate")
        end

        output_options = options.fetch("output_options", {})
        if FORMATS_WITHOUT_PROFILE_SUPPORT.include?(format)
          output_options.delete("profile")
        elsif DragonflyLibvips.auto_profile
          output_options["profile"] ||= input_options.fetch("profile", EPROFILE_PATH)
        end
        output_options.delete("Q") unless /jpg|jpeg/i.match?(format.to_s)
        output_options["format"] ||= format.to_s if /bmp/i.match?(format.to_s)

        img = ::Vips::Image.new_from_file(content.path, **DragonflyLibvips.symbolize_keys(input_options))

        if output_options.include?("profile")
          img = img.icc_transform(
            output_options["profile"],
            embedded: true,
            intent: :relative,
            black_point_compensation: true
          )
        end

        content.update(
          img.write_to_buffer(".#{format}", **DragonflyLibvips.symbolize_keys(output_options)),
          "name" => "temp.#{format}",
          "format" => format
        )
        content.ext = format
      end

      def update_url(url_attributes, format, _options = {})
        url_attributes.ext = format.to_s
      end
    end
  end
end
