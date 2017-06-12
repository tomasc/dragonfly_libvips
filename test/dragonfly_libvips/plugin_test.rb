require 'test_helper'
require 'openssl'

module DragonflyLibvips
  describe Plugin do
    let(:app) { test_app.configure_with(:libvips) }
    let(:image) { app.fetch_file(SAMPLES_DIR.join('beach.png')) }

    describe 'analysers' do
      it 'returns the width' do
        image.width.must_equal 280
      end

      it 'returns the height' do
        image.height.must_equal 355
      end

      it 'returns the aspect ratio' do
        image.aspect_ratio.must_equal (280.0 / 355.0)
      end

      it "says if it's portrait" do
        image.portrait?.must_equal true
        image.portrait.must_equal true # for use with magic attributes
      end

      it "says if it's landscape" do
        image.landscape?.must_equal false
        image.landscape.must_equal false # for use with magic attributes
      end

      it 'returns the format' do
        image.format.must_equal 'png'
      end

      it "says if it's an image" do
        image.image?.must_equal true
        image.image.must_equal true # for use with magic attributes
      end
    end

    describe 'processors that change the url' do
      before do
        app.configure { url_format '/:name' }
      end

      describe 'encode' do
        it 'sanity check' do
          thumb = image.encode('png')
          thumb.url.must_match(/^\/beach\.png\?.*job=\w+/)
          thumb.format.must_equal 'png'
          thumb.meta['format'].must_equal 'png'
        end
      end

      describe 'rotate' do
        it 'sanity check' do
          thumb = image.rotate(90, format: 'png')
          thumb.url.must_match(/^\/beach\.png\?.*job=\w+/)
          thumb.format.must_equal 'png'
          thumb.meta['format'].must_equal 'png'
        end
      end

      describe 'thumb' do
        it 'sanity check' do
          thumb = image.thumb('100x', format: 'png')
          thumb.url.must_match(/^\/beach\.png\?.*job=\w+/)
          thumb.format.must_equal 'png'
          thumb.meta['format'].must_equal 'png'
        end
      end
    end

    describe 'other processors' do
      describe 'encode' do
        it 'encodes the image to the correct format' do
          image.encode!('jpg')
          image.format.must_equal 'jpeg'
        end

        it 'allows for extra args' do
          image.encode!('jpg', output_options: { Q: 1 })
          image.format.must_equal 'jpeg'
          image.size.must_be :<, 65_000
        end
      end

      describe 'rotate' do
        it 'should rotate by 90 degrees' do
          image.rotate!(90)
          image.width.must_equal 355
          image.height.must_equal 280
        end
      end
    end
  end
end
