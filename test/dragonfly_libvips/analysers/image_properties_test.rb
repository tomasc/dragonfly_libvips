require 'test_helper'

describe DragonflyLibvips::Analysers::ImageProperties do
  let(:app) { test_libvips_app }
  let(:analyser) { DragonflyLibvips::Analysers::ImageProperties.new }
  let(:content) { Dragonfly::Content.new(app, SAMPLES_DIR.join('beach.png')) } # 280x355

  describe 'call' do
    it 'returns a hash of properties' do
      analyser.call(content).must_equal('format' => 'png', 'width' => 280, 'height' => 355, 'xres' => 72.0, 'yres' => 72.0)
    end
  end
end
