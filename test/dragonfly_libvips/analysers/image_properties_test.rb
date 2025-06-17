# frozen_string_literal: true

require "test_helper"

describe DragonflyLibvips::Analysers::ImageProperties do
  let(:app) { test_libvips_app }
  let(:analyser) { DragonflyLibvips::Analysers::ImageProperties.new }
  let(:png) { Dragonfly::Content.new(app, SAMPLES_DIR.join("sample.png")) } # 280x355
  let(:jpg) { Dragonfly::Content.new(app, SAMPLES_DIR.join("sample.jpg")) } # 280x355

  it { _(analyser.call(png)).must_equal("format" => "png", "width" => 280, "height" => 355, "xres" => 72.0, "yres" => 72.0, "has_alpha" => true, "progressive" => false) }

  describe "jpgs" do
    it { _(analyser.call(jpg)["progressive"]).must_equal false }
    it { _(analyser.call(jpg)["has_alpha"]).must_equal false }
  end
end
