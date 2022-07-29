# frozen_string_literal: true
require 'dragonfly'
require 'dragonfly_libvips/dimensions'
require 'dragonfly_libvips/geometry'
require 'dragonfly_libvips/plugin'
require 'dragonfly_libvips/processors'
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
    raw
    v
    vips
  ]

  FORMATS_WITHOUT_PROFILE_SUPPORT = %w[]

  # ImageMagick geometry strings. These from Dragonfly::ImageMagick, via RefineryCMS

  area         = /(?<area>\d+@)/
  gravity      = /#(?<gravity>\w{1,2})/
  modifiers    = /(?<modifiers>[><%^!])/
  offset       = /(?<x_offset>[+-]\d+)?(?<y_offset>[+-]\d+)/
  width_height = /(?<geom_w>\d+)?x?(?<geom_h>\d+)?/

  RESIZE_GEOMETRY = /\A#{width_height}#{modifiers}?\z|\A#{area}\z/ # e.g. '300x200!' or '900@'
  CROPPED_RESIZE_GEOMETRY = /\A#{width_height}#{gravity}?\z/ # e.g. '20x50#ne'
  CROP_GEOMETRY = /\A#{width_height}(#{offset})?#{gravity}?\z/ # e.g. '30x30+10+10

  def self.stringify_keys(**hash )
    hash.transform_keys { |k| k.to_s }
  end

  def self.symbolize_keys(**hash)
    hash.transform_keys { |k| k.to_sym } if hash
  end
end
