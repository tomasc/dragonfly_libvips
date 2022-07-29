require 'dragonfly'
require 'dragonfly_libvips/dimensions'
require 'dragonfly_libvips/plugin'
require 'dragonfly_libvips/version'
require 'vips'

module DragonflyLibvips
  class UnsupportedFormat < RuntimeError; end
  class UnsupportedOutputFormat < RuntimeError; end

  CMYK_PROFILE_PATH = File.expand_path('../vendor/cmyk.icm', __dir__)
  EPROFILE_PATH = File.expand_path('../vendor/sRGB_v4_ICC_preference.icc', __dir__)

  SUPPORTED_FORMATS = begin
    output = `vips -l | grep -i ForeignLoad`
    output.scan(/\.(\w{1,4})/).flatten.compact.sort.map(&:downcase).uniq
  end

  SUPPORTED_OUTPUT_FORMATS = begin
    output = `vips -l | grep -i ForeignSave`
    output.scan(/\.(\w{1,4})/).flatten.compact.sort.map(&:downcase).uniq
  end - %w[
    csv
    fit
    fits
    fts
    mat
    pbm
    pfm
    pgm
    ppm
    v
    vips
  ]

  FORMATS_WITHOUT_PROFILE_SUPPORT = %w[avif bmp dz gif hdr webp heic heif]

  private

  def self.stringify_keys(hash = {})
    hash.each_with_object({}) { |(k, v), memo| memo[k.to_s] = v }
  end

  def self.symbolize_keys(hash = {})
    hash.each_with_object({}) { |(k, v), memo| memo[k.to_sym] = v }
  end
end
