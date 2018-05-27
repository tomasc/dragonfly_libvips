require 'dragonfly'
require 'dragonfly_libvips/dimensions'
require 'dragonfly_libvips/plugin'
require 'dragonfly_libvips/version'
require 'vips'

module DragonflyLibvips
  class UnsupportedFormat < RuntimeError; end

  CMYK_PROFILE_PATH = File.expand_path('../vendor/cmyk.icm', __dir__)
  EPROFILE_PATH = File.expand_path('../vendor/sRGB_v4_ICC_preference.icc', __dir__)

  SUPPORTED_FORMATS = begin
    output = `vips -l | grep -i ForeignLoad`
    output.scan(/\.(\w{1,4})/).flatten.sort.uniq
  end

  SUPPORTED_OUTPUT_FORMATS = begin
    output = `vips -l | grep -i ForeignSave`
    output.scan(/\.(\w{1,4})/).flatten.sort.uniq
  end - %w[
    csv
    mat
    pbm
    pfm
    pgm
    ppm
    v
    vips
    webp
  ]
end
