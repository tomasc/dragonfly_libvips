require 'test_helper'

describe DragonflyLibvips::Processors::ExtractArea do
  let(:app) { test_libvips_app }
  let(:content) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.png')) } # 280x355
  let(:processor) { DragonflyLibvips::Processors::ExtractArea.new }

  let(:x) { 100 }
  let(:y) { 100 }
  let(:width) { 100 }
  let(:height) { 200 }

  describe 'keep format' do
    before { processor.call(content, x, y, width, height) }

    it { content.must_have_width width }
    it { content.must_have_height height }
  end

  describe 'convert to format' do
    before { processor.call(content, x, y, width, height, format: 'jpg') }

    it { content.must_have_width width }
    it { content.must_have_height height }
    it { content.ext.must_equal 'jpg' }
  end

  describe 'tempfile has extension' do
    let(:format) { 'jpg' }
    before { processor.call(content, x, y, width, height, format: format) }
    it { content.tempfile.path.must_match /\.#{format}\z/ }
  end
end
