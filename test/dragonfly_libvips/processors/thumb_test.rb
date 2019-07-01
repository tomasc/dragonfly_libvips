require 'test_helper'
require 'ostruct'

describe DragonflyLibvips::Processors::Thumb do
  let(:app) { test_libvips_app }
  let(:image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.png')) } # 280x355
  let(:pdf) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.pdf')) }
  let(:jpg) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.jpg')) }
  let(:cmyk) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample_cmyk.jpg')) }
  let(:gif) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.gif')) }
  let(:anim_gif) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample_anim.gif')) }
  let(:landscape_image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('landscape_sample.png')) } # 355x280
  let(:processor) { DragonflyLibvips::Processors::Thumb.new }

  it 'raises an error if an unrecognized string is given' do
    assert_raises(ArgumentError) do
      processor.call(image, '30x40#ne!')
    end
  end

  describe 'cmyk images' do
    before { processor.call(cmyk, '30x') }
    it { cmyk.must_have_width 30 }
  end

  describe 'resizing' do
    describe 'xNN' do
      before { processor.call(landscape_image, 'x30') }
      it { landscape_image.must_have_width 38 }
      it { landscape_image.must_have_height 30 }
    end

    describe 'NNx' do
      before { processor.call(image, '30x') }
      it { image.must_have_width 30 }
      it { image.must_have_height 38 }
    end

    describe 'NNxNN' do
      before { processor.call(image, '30x30') }
      it { image.must_have_width 24 }
      it { image.must_have_height 30 }
    end

    describe 'NNxNN>' do
      describe 'if the image is smaller than specified' do
        before { processor.call(image, '1000x1000>') }
        it { image.must_have_width 280 }
        it { image.must_have_height 355 }
      end

      describe 'if the image is larger than specified' do
        before { processor.call(image, '30x30>') }
        it { image.must_have_width 24 }
        it { image.must_have_height 30 }
      end
    end

    describe 'NNxNN<' do
      describe 'if the image is larger than specified' do
        before { processor.call(image, '10x10<') }
        it { image.must_have_width 280 }
        it { image.must_have_height 355 }
      end

      describe 'if the image is smaller than specified' do
        before { processor.call(image, '500x500<') }
        it { image.must_have_width 394 }
        it { image.must_have_height 500 }
      end
    end
  end

  describe 'pdf' do
    describe 'resize' do
      before { processor.call(pdf, '500x500', format: 'jpg') }
      # it { pdf.must_have_width 386 }
      it { pdf.must_have_height 500 }
    end

    describe 'page param' do
      before { processor.call(pdf, '500x500', format: 'jpg', input_options: { page: 0 }) }
      # it { pdf.must_have_width 386 }
      it { pdf.must_have_height 500 }
    end
  end

  describe 'jpg' do
    describe 'progressive' do
      before { processor.call(jpg, '300x', output_options: { interlace: true }) }
      it { (`vipsheader -f jpeg-multiscan #{jpg.file.path}`.to_i == 1).must_equal true }
    end
  end

  describe 'gif' do
    describe 'static' do
      before { processor.call(gif, '200x') }
      it { gif.must_have_width 200 }
    end

    describe 'animated' do
      before { processor.call(anim_gif, '200x') }
      it {
        skip 'waiting for full support'
        gif.must_have_width 200
      }
    end
  end

  describe 'format' do
    let(:url_attributes) { OpenStruct.new }

    describe 'when format passed in' do
      before { processor.call(image, '2x2', format: 'jpeg', output_options: { Q: 50 }) }
      it { image.ext.must_equal 'jpeg' }
      it { image.size.must_be :<, 65_000 }
    end

    describe 'when format not passed in' do
      before { processor.call(image, '2x2') }
      it { image.ext.must_equal 'png' }
    end

    describe 'when ext passed in' do
      before { processor.update_url(url_attributes, '2x2', 'format' => 'png') }
      it { url_attributes.ext.must_equal 'png' }
    end

    describe 'when ext not passed in' do
      before { processor.update_url(url_attributes, '2x2') }
      it { url_attributes.ext.must_be_nil }
    end
  end

  describe 'tempfile has extension' do
    let(:format) { 'jpg' }
    before { processor.call(image, '100x', format: 'jpg') }
    it { image.tempfile.path.must_match /\.#{format}\z/ }
  end
end
