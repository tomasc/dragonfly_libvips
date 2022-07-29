# CHANGELOG

## 2.5.0

* Fix ruby 3.0+ compatibility by @Bartuz

## 2.4.2

* Add `webp` as supported format, and `aviz` and `heif` to formats without profile support (#14) by @asgerb

## 2.4.1

* Fix misspelled UnsupportedOutputFormat (#13) by @asgerb
* Fix broken links in README (#12) by @NARKOZ

## 2.4.0

* symbolize `input_options` and `output_options` to avoid argument errors coming from `ruby-vips`

## 2.3.3

* locks `ruby-vips` to `< 2.0.14`
* adds support for `libvips` `8.8.0`

## 2.3.2

* FIX: support for .gif

## 2.3.1

* improved `SUPPORTED_FORMATS` matching that ignores case

## 2.3.0

* add support for progressive JPEGs

## 2.2.0

* add `SUPPORTED_FORMATS` and `SUPPORTED_OUTPUT_FORMATS` and raise errors when formats are not matching
* add more thorough tests for supported formats
* skip unnecessary conversion from-to same format
* add `extract_area` processor

## 2.1.3

* make sure the downcase analyser survives nil

## 2.1.2

* changed image properties analyser to downcase the image's format

## 2.1.1

* add `CMYK` support using the `cmyk.icm` profile

## 2.1.0

* `thumb` process refactored for `Vips::Image.thumbnail`, with faster performance

## 2.0.1

* `ruby-vips` updated to `>= 2.0.1`
* added `autorotate` support, based on `orientation` value from EXIF tags (JPEG only)

## 2.0.0

* `ruby-vips` updated to `~> 2.0`

## 1.0.4

* `vips` is required closer to when the classes are called, in hope of fixing [#107](https://github.com/jcupitt/ruby-vips/issues/107)

## 1.0.0

* rewritten to use `ruby-vips` instead of CLI vips utils, which should result in better performance
* processors `convert`, `vips` and `vipsthumbnail` have been removed
