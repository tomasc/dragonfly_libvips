require 'test_helper'

describe DragonflyLibvips::Processors::Encode do
  let(:app) { test_libvips_app }
  let(:image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('beach.png')) } # 280x355
  let(:pdf) { Dragonfly::Content.new(app, SAMPLES_DIR.join('memo.pdf')) }
  let(:processor) { DragonflyLibvips::Processors::Encode.new }

  it 'converts to specified format' do
    processor.call(image, 'jpg')
    image.ext.must_equal 'jpg'
  end

  it 'allows for options' do
    processor.call(image, 'jpg', output_options: { Q: 50 })
    image.ext.must_equal 'jpg'
  end

  it 'supports PDF' do
    processor.call(pdf, 'jpg', input_options: { page: 0, dpi: 300 }, output_options: { Q: 50 })
    pdf.ext.must_equal 'jpg'
  end
end
