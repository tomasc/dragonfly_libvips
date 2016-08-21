# Dragonfly libvips

[![Build Status](https://travis-ci.org/tomasc/dragonfly_libvips.svg)](https://travis-ci.org/tomasc/dragonfly_libvips) [![Gem Version](https://badge.fury.io/rb/dragonfly_libvips.svg)](http://badge.fury.io/rb/dragonfly_libvips) [![Coverage Status](https://img.shields.io/coveralls/tomasc/dragonfly_libvips.svg)](https://coveralls.io/r/tomasc/dragonfly_pdf)

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

## Dependencies

The [vips](http://www.vips.ecs.soton.ac.uk/index.php?title=Supported) library and its [dependencies](https://github.com/jcupitt/libvips#dependencies).

## Usage

Configure your app the usual way:

```ruby
Dragonfly.app.configure do
  plugin :libvips
end
```

### Processors

#### Thumb

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

#### Encode

Change the encoding with

```ruby
image.encode('jpg')
```

optionally pass output arguments (specific to format)

```ruby
image.encode('jpg', 'Q=50')
```

#### Rotate

Rotate a number of degrees with

```ruby
image.rotate(90)
```

#### Vips

Perform an arbitrary `vips` command

```ruby
image.vips('resize', '0.5', { 'input_args' => 'page=2', 'output_args' => 'Q=50', 'format' => 'jpg' })
```

corresponds to the command-line

```
vips resize <original_path>[page=2] <new_path>[Q=50] 0.5
```

#### Vipsthumbnail

Perform an arbitrary `vipsthumbnail` command

```ruby
image.vipsthumbnail('--size=100x100', { 'input_args' => 'page=2', 'output_args' => 'Q=50', 'format' => 'jpg' })
```

corresponds to the command-line

```
vipsthumbnail  <original_path>[page=2] --size=100x100 -o <new-path>[Q=50]  --eprofile=./vendor/sRGB_v4_ICC_preference.icc
```

Please note that unless specified a default sRGB profile is added (required for conversion from CMYK, for example). It can be overridden by specifying alternative on in the processors args:

```ruby
image.vipsthumbnail('--size=100x100 --eprofile=./my_custom_profile.icc')
```


### Analysers

The following methods are provided

```ruby
image.width # => 280
image.height # => 355
image.aspect_ratio # => 0.788732394366197
image.portrait? # => true
image.landscape? # => false
image.format # => 'png'
image.image? # => true
```

### Configuration

```ruby
Dragonfly.app.configure do
  plugin :libvips,
          vips_command: "/opt/local/bin/vips" # defaults to "vips"
          vipsheader_command: "/opt/local/bin/vipsheader" # defaults to "vipsheader"
          vipsthumbnail_command: "/opt/local/bin/vipsthumbnail" # defaults to "vipsthumbnail"
end
```

## Acknowledgements

This plugin, its structure, sample files, tests as well as this README are based on the original Dragonfly's [ImageMagick plugin](http://markevans.github.io/dragonfly/imagemagick) by Mark Evans.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/tomasc/dragonfly_libvips>.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
