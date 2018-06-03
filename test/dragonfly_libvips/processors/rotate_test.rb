require 'test_helper'

describe DragonflyLibvips::Processors::Rotate do
  let(:app) { test_libvips_app }
  let(:content) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.png')) } # 280x355
  let(:processor) { DragonflyLibvips::Processors::Rotate.new }

  describe 'rotate 90' do
    before { processor.call(content, 90) }

    it { content.must_have_width 355 }
    it { content.must_have_height 280 }
  end

  describe 'rotate 180' do
    before { processor.call(content, 180) }

    it { content.must_have_width 280 }
    it { content.must_have_height 355 }
  end

  describe 'rotate 270' do
    before { processor.call(content, 270) }

    it { content.must_have_width 355 }
    it { content.must_have_height 280 }
  end

  describe 'rotate with format' do
    before { processor.call(content, 90, format: 'jpg') }

    it { content.must_have_width 355 }
    it { content.must_have_height 280 }
    it { content.ext.must_equal 'jpg' }
  end

  describe 'tempfile has extension' do
    let(:format) { 'jpg' }
    before { processor.call(content, 90, format: format) }
    it { content.tempfile.path.must_match /\.#{format}\z/ }
  end
end
