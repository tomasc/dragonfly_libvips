require 'test_helper'
require 'ostruct'

describe DragonflyLibvips::Processors::Thumb do
  let(:app) { test_libvips_app }
  let(:image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('beach.png')) } # 280x355
  let(:pdf) { Dragonfly::Content.new(app, SAMPLES_DIR.join('memo.pdf')) }
  let(:landscape_image) { Dragonfly::Content.new(app, SAMPLES_DIR.join('landscape_beach.png')) } # 355x280
  let(:processor) { DragonflyLibvips::Processors::Thumb.new }

  it 'raises an error if an unrecognized string is given' do
    assert_raises(ArgumentError) do
      processor.call(image, '30x40#ne!')
    end
  end

  describe 'resizing' do
    it 'works with xNN' do
      processor.call(landscape_image, 'x30')
      landscape_image.must_have_width 38
      landscape_image.must_have_height 30
    end

    it 'works with NNx' do
      processor.call(image, '30x')
      image.must_have_width 30
      image.must_have_height 38
    end

    it 'works with NNxNN' do
      processor.call(image, '30x30')
      image.must_have_width 24
      image.must_have_height 30
    end

    describe 'NNxNN>' do
      it "doesn't resize if the image is smaller than specified" do
        processor.call(image, '1000x1000>')
        image.must_have_width 280
        image.must_have_height 355
      end

      it 'resizes if the image is larger than specified' do
        processor.call(image, '30x30>')
        image.must_have_width 24
        image.must_have_height 30
      end
    end

    describe 'NNxNN<' do
      it "doesn't resize if the image is larger than specified" do
        processor.call(image, '10x10<')
        image.must_have_width 280
        image.must_have_height 355
      end

      it 'resizes if the image is smaller than specified' do
        processor.call(image, '500x500<')
        image.must_have_width 394
        image.must_have_height 500
      end
    end
  end

  describe 'format' do
    let(:url_attributes) { OpenStruct.new }

    it 'changes the format if passed in' do
      processor.call(image, '2x2', format: 'jpeg', output_options: { Q: 50 })
      image.ext.must_equal 'jpeg'
      image.size.must_equal 61_747
    end

    it "doesn't change the format if not passed in" do
      processor.call(image, '2x2')
      image.ext.must_equal 'png'
    end

    it 'updates the url ext if passed in' do
      processor.update_url(url_attributes, '2x2', 'format' => 'png')
      url_attributes.ext.must_equal 'png'
    end

    it "doesn't update the url ext if not passed in" do
      processor.update_url(url_attributes, '2x2')
      url_attributes.ext.must_be_nil
    end
  end
end
