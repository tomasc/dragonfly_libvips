# frozen_string_literal: true

require "test_helper"

describe DragonflyLibvips::Processors::ExtractArea do
  let(:app) { test_libvips_app }
  let(:content) { Dragonfly::Content.new(app, SAMPLES_DIR.join("sample.png")) } # 280x355
  let(:processor) { DragonflyLibvips::Processors::ExtractArea.new }

  let(:x) { 100 }
  let(:y) { 100 }
  let(:width) { 100 }
  let(:height) { 200 }

  describe "keep format" do
    before { processor.call(content, x, y, width, height) }

    it { _(content).must_have_width width }
    it { _(content).must_have_height height }
  end

  describe "convert to format" do
    before { processor.call(content, x, y, width, height, format: "jpg") }

    it { _(content).must_have_width width }
    it { _(content).must_have_height height }
    it { _(content.ext).must_equal "jpg" }
  end

  describe "tempfile has extension" do
    before { processor.call(content, x, y, width, height, format: "jpg") }
    it { _(content.tempfile.path).must_match(/\.jpg\z/) }
  end

  describe "icc profile embedding" do
    before { processor.call(content, x, y, width, height, format: "jpg") }

    it "embeds an ICC profile" do
      output = `vipsheader -a #{content.file.path} | grep -i icc`
      _(output).wont_be_empty
    end
  end
end
