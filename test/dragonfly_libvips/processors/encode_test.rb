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

      DragonflyLibvips::SUPPORTED_OUTPUT_FORMATS.each do |output_format|
        it("#{format} to #{output_format}") do
          result = content.encode(output_format)
          content.encode(output_format).mime_type.must_equal Rack::Mime.mime_type(".#{output_format}")
          content.encode(output_format).size.must_be :>, 0
        end
      end
    end
  end

  describe 'allows for options' do
    before { processor.call(content_image, 'jpg', output_options: { Q: 50 }) }
    it { content_image.ext.must_equal 'jpg' }
  end

  describe 'tempfile has extension' do
    let(:format) { 'jpg' }
    before { processor.call(content_image, format) }
    it { content_image.tempfile.path.must_match /\.#{format}\z/ }
  end
end
