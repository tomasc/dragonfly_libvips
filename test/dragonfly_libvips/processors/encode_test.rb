require 'test_helper'

describe DragonflyLibvips::Processors::Encode do
  let(:app) { test_libvips_app }
  let(:content_image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('beach.png')) } # 280x355
  let(:content_pdf) { Dragonfly::Content.new(app, SAMPLES_DIR.join('memo.pdf')) }
  let(:processor) { DragonflyLibvips::Processors::Encode.new }

  describe 'converts to specified format' do
    before { processor.call(content_image, 'jpg') }
    it { content_image.ext.must_equal 'jpg' }
  end

  describe 'allows for options' do
    before { processor.call(content_image, 'jpg', output_options: { Q: 50 }) }
    it { content_image.ext.must_equal 'jpg' }
  end

  describe 'supports PDF' do
    before { processor.call(content_pdf, 'jpg', input_options: { page: 0, dpi: 300 }, output_options: { Q: 50 }) }
    it { content_pdf.ext.must_equal 'jpg' }
  end
end
