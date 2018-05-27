require 'test_helper'
require 'ostruct'

describe DragonflyLibvips::Processors::Thumb do
  let(:app) { test_libvips_app }
  let(:image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.png')) } # 280x355
  let(:pdf) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.pdf')) }
  let(:cmyk) { Dragonfly::Content.new(app, SAMPLES_DIR.join('sample.jpg')) }
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
      it { pdf.must_have_width 387 }
      it { pdf.must_have_height 500 }
    end

    describe 'page param' do
      before { processor.call(pdf, '500x500', format: 'jpg', input_options: { page: 0 }) }
      it { pdf.must_have_width 387 }
      it { pdf.must_have_height 500 }
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
end
