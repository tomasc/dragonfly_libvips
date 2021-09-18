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
          _(content.encode(output_format).mime_type).must_equal Rack::Mime.mime_type(".#{output_format}")
          _(content.encode(output_format).size).must_be :>, 0
          _(content.encode(output_format).tempfile.path).must_match /\.#{output_format_short(output_format)}\z/
        end
      end
    end
  end

  describe 'allows for options' do
    before { processor.call(content_image, 'jpg', output_options: { Q: 50 }) }
    it { _(content_image.ext).must_equal 'jpg' }
  end

  def output_format_short(format)
    case format
    when 'tiff' then 'tif'
    # when 'jpeg' then 'jpg'
    else format
    end
  end
end
