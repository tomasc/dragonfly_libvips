require 'test_helper'

describe DragonflyLibvips::Processors::Vips do
  let(:app) { test_app }
  let(:image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('beach.png')) } # 280x355
  let(:pdf) { Dragonfly::Content.new(app, SAMPLES_DIR.join('memo.pdf')) }
  let(:processor) { DragonflyLibvips::Processors::Vips.new }

  it 'allows for general vips commands' do
    processor.call(image, 'resize', '0.5')
    image.must_have_width 140
    image.must_have_height 178
  end

  it 'allows for general vips commands with added format' do
    processor.call(image, 'resize', '0.5', 'format' => 'jpg')
    image.must_have_width 140
    image.must_have_height 178
    image.must_have_format 'jpeg'
    image.meta['format'].must_equal 'jpg'
  end

  it 'allows for general vips commands with added :input_args' do
    processor.call(pdf, 'copy', '', 'format' => 'jpg', 'input_args' => { page: 0 })
    pdf.must_have_format 'jpeg'
    pdf.meta['format'].must_equal 'jpg'
  end

  it 'allows for general vips commands with added :output_args' do
    processor.call(image, 'resize', '0.5', 'format' => 'jpg', 'output_args' => { Q: 10 })
    image.must_have_width 140
    image.must_have_format 'jpeg'
    image.meta['format'].must_equal 'jpg'
  end

  it 'works for files with spaces in the name' do
    image = Dragonfly::Content.new(app, SAMPLES_DIR.join('white pixel.png'))
    processor.call(image, 'resize', '2')
    image.must_have_width 2
  end

  it 'updates the url with format if given' do
    url_attributes = Dragonfly::UrlAttributes.new
    processor.update_url(url_attributes, 'resize', '2', 'format' => 'jpg')
    url_attributes.ext.must_equal 'jpg'
  end
end
