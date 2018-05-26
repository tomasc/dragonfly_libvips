require 'test_helper'
require 'openssl'

module DragonflyLibvips
  describe Plugin do
    let(:app) { test_app.configure_with(:libvips) }
    let(:content) { app.fetch_file(SAMPLES_DIR.join('beach.png')) }

    describe 'analysers' do
      it { content.width.must_equal 280 }
      it { content.height.must_equal 355 }
      it { content.aspect_ratio.must_equal (280.0 / 355.0) }
      it { content.xres.must_equal 72.0 }
      it { content.yres.must_equal 72.0 }

      it { content.must_be :portrait? }
      it { content.portrait.must_equal true } # for use with magic attributes
      it { content.wont_be :landscape? }
      it { content.landscape.must_equal false } # for use with magic attributes

      it { content.format.must_equal 'png' }

      it { content.must_be :image? }
      it { content.image.must_equal true } # for use with magic attributes
      it { app.create('blah').wont_be :image? }
    end

    describe 'processors that change the url' do
      before { app.configure { url_format '/:name' } }

      describe 'encode' do
        let(:thumb) { content.encode('png') }

        it { thumb.url.must_match(/^\/beach\.png\?.*job=\w+/) }
        it { thumb.format.must_equal 'png' }
      end

      describe 'rotate' do
        let(:thumb) { content.rotate(90, format: 'png') }

        it { thumb.url.must_match(/^\/beach\.png\?.*job=\w+/) }
        it { thumb.format.must_equal 'png' }
        it { thumb.meta['format'].must_equal 'png' }
      end

      describe 'thumb' do
        let(:thumb) { content.thumb('100x', format: 'png') }

        it { thumb.url.must_match(/^\/beach\.png\?.*job=\w+/) }
        it { thumb.format.must_equal 'png' }
        it { thumb.meta['format'].must_equal 'png' }
      end
    end

    describe 'other processors' do
      describe 'encode' do
        it { content.encode('jpg').format.must_equal 'jpg' }
        it { content.encode('jpg', output_options: { Q: 1 }).format.must_equal 'jpg' }
        it { content.encode('jpg', output_options: { Q: 1 }).size.must_be :<, 65_000 }
      end

      describe 'rotate' do
        it { content.rotate(90).width.must_equal 355 }
        it { content.rotate(90).height.must_equal 280 }
      end
    end
  end
end
