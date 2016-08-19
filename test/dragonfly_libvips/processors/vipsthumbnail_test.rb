require 'test_helper'

describe DragonflyLibvips::Processors::Vipsthumbnail do
  def sample_content(name)
    Dragonfly::Content.new(app, SAMPLES_DIR.join(name))
  end

  let (:app) { test_libvips_app }
  let (:image) { sample_content('beach.png') } # 280x355
  let (:pdf) { sample_content('memo.pdf') }
  let (:processor) { DragonflyLibvips::Processors::Vipsthumbnail.new }

  it 'allows for general vipsthumbnail commands' do
    processor.call(image, '--size=100x100')
    image.must_have_height 100
  end

  it 'allows for general vipsthumbnail commands with added :input_args' do
    processor.call(pdf, '--size=100x100', 'input_args' => 'page=0', 'format' => 'jpg')
    pdf.must_have_format 'jpeg'
    pdf.meta['format'].must_equal 'jpg'
  end

  it 'allows for general vipsthumbnail commands with added :output_args' do
    processor.call(image, '--size=100x100', 'output_args' => 'Q=50', 'format' => 'jpg')
    image.must_have_height 100
    image.must_have_format 'jpeg'
    image.meta['format'].must_equal 'jpg'
  end

  it 'allows for specifying format' do
    processor.call(image, '--size=100x100', 'format' => 'jpg')
    image.must_have_format 'jpeg'
    image.meta['format'].must_equal 'jpg'
  end

  it 'updates the url with format if given' do
    url_attributes = Dragonfly::UrlAttributes.new
    processor.update_url(url_attributes, '--size=100x100', 'format' => 'jpg')
    url_attributes.ext.must_equal 'jpg'
  end
end
