require 'test_helper'

describe DragonflyLibvips::Processors::Encode do
  let(:app) { test_libvips_app }
  let(:content_image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.png')) } # 280x355
  let(:processor) { DragonflyLibvips::Processors::Encode.new }

  DragonflyLibvips::SUPPORTED_FORMATS.each do |format|
    unless File.exists?(SAMPLES_DIR.join("sample.#{format}"))
      it(format) { skip "sample.#{format} does not exist, skipping" }
      next
    end

    describe format.to_s do
      let(:content) { app.fetch_file SAMPLES_DIR.join("sample.#{format}") }
      let(:result) { content.encode('jpg') }
      it { content.encode('jpg').ext.must_equal 'jpg' }
      it { content.encode('jpg').mime_type.must_equal 'image/jpeg' }
      it { content.encode('jpg').size.must_be :>, 0 }
    end
  end

  DragonflyLibvips::SUPPORTED_OUTPUT_FORMATS.each do |format|
    describe "output to #{format}" do
      let(:content) { app.fetch_file SAMPLES_DIR.join("sample.png") }
      let(:result) { content.encode(format) }
      it { result.ext.must_equal format }
      it { result.mime_type.must_equal Rack::Mime.mime_type(".#{format}") }
      it { result.size.must_be :>, 0 }
    end
  end

  describe 'allows for options' do
    before { processor.call(content_image, 'jpg', output_options: { Q: 50 }) }
    it { content_image.ext.must_equal 'jpg' }
  end
end
