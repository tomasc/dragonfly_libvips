# Dragonfly libvips

[![Build Status](https://travis-ci.org/tomasc/dragonfly_libvips.svg)](https://travis-ci.org/tomasc/dragonfly_libvips) [![Gem Version](https://badge.fury.io/rb/dragonfly_libvips.svg)](http://badge.fury.io/rb/dragonfly_libvips) [![Coverage Status](https://img.shields.io/coveralls/tomasc/dragonfly_libvips.svg)](https://coveralls.io/r/tomasc/dragonfly_libvips)

Dragonfly analysers and processors for [libvips](https://github.com/jcupitt/libvips) image processing library

From the libvips README:

> libvips is a 2D image processing library. Compared to similar libraries, [libvips runs quickly and uses little memory](http://www.vips.ecs.soton.ac.uk/index.php?title=Speed_and_Memory_Use). libvips is licensed under the LGPL 2.1+.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dragonfly_libvips'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install dragonfly_libvips
```

### libvips

If you run into trouble installing `libvips` with Ruby introspection on Linux, follow the [build steps here](https://github.com/tomasc/dragonfly_libvips/blob/master/.travis.yml). Please note the importance of `gobject-introspection` and `libgirepository1.0-dev` plus the `export GI_TYPELIB_PATH=/usr/local/lib/girepository-1.0/` and `ldconfig`.

## Dependencies

The [vips](http://www.vips.ecs.soton.ac.uk/index.php?title=Supported) library and its [dependencies](https://github.com/jcupitt/libvips#dependencies).

## Usage

Configure your app the usual way:

```ruby
Dragonfly.app.configure do
  plugin :libvips
end
```

## Supported Formats

List of supported formats (based on your build and version of the `libvips` library) is available as:

```ruby
DragonflyLibvips::SUPPORTED_FORMATS # => ["csv", "dz", "gif", …]
DragonflyLibvips::SUPPORTED_OUTPUT_FORMATS # => ["csv", "dz", "gif", …]
```

## Processors

### Thumb

Create a thumbnail by resizing/cropping

```ruby
image.thumb('40x30')
```

Below are some examples of geometry strings for `thumb`:

```ruby
'400x300' # resize, maintain aspect ratio
'400x' # resize width, maintain aspect ratio
'x300' # resize height, maintain aspect ratio
'400x300<' # resize only if the image is smaller than this
'400x300>' # resize only if the image is larger than this
```

### Encode

Change the encoding with

```ruby
image.encode('jpg')
```

### Extract Area

Extract an area from an image.

```ruby
image.extract_area(x, y, width, height)
```

### Rotate

Rotate a number of degrees with

```ruby
image.rotate(90)
```

### Options

All processors support `input_options` and `output_options` for passing additional options to vips. For example:

```ruby
image.encode('jpg', output_options: { Q: 50 })
pdf.encode('jpg', input_options: { page: 0, dpi: 600 })
```

Defaults:

```ruby
input_options: { access: :sequential }
output_options: { profile: … } # embeds 'sRGB_v4_ICC_preference.icc' profile included with this gem
```

## Analysers

The following methods are provided

```ruby
image.width # => 280
image.height # => 355
image.xres # => 72.0
image.yres # => 72.0
image.aspect_ratio # => 0.788732394366197
image.portrait? # => true
image.landscape? # => false
image.format # => 'png'
image.image? # => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/tomasc/dragonfly_libvips>.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
