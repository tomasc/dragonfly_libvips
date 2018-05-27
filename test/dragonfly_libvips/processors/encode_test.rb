require 'test_helper'

describe DragonflyLibvips::Processors::Encode do
  let(:app) { test_libvips_app }
  let(:content_image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.png')) } # 280x355
  let(:processor) { DragonflyLibvips::Processors::Encode.new }

  describe 'SUPPORTED_FORMATS' do
    DragonflyLibvips::SUPPORTED_FORMATS.each do |format|
      unless File.exist?(SAMPLES_DIR.join("sample.#{format}"))
        it(format) { skip "sample.#{format} does not exist, skipping" }
        next
      end

      let(:content) { app.fetch_file SAMPLES_DIR.join("sample.#{format}") }
      it(format) do
        result = content.encode('jpg')
        content.encode('jpg').ext.must_equal 'jpg'
        content.encode('jpg').mime_type.must_equal 'image/jpeg'
        content.encode('jpg').size.must_be :>, 0
      end
    end
  end

  describe 'SUPPORTED_OUTPUT_FORMATS' do
    DragonflyLibvips::SUPPORTED_OUTPUT_FORMATS.each do |format|
      let(:content) { app.fetch_file SAMPLES_DIR.join("sample.png") }
      it(format) do
        result = content.encode(format)
        result.ext.must_equal format
        result.mime_type.must_equal Rack::Mime.mime_type(".#{format}")
        result.size.must_be :>, 0
      end
    end
  end

  describe 'allows for options' do
    before { processor.call(content_image, 'jpg', output_options: { Q: 50 }) }
    it { content_image.ext.must_equal 'jpg' }
  end
end
