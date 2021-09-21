require 'test_helper'
require 'openssl'

module DragonflyLibvips
  describe Plugin do
    let(:app) { test_app.configure_with(:libvips) }
    let(:content) { app.fetch_file(SAMPLES_DIR.join('sample.png')) }

    describe 'analysers' do
      it { _(content.width).must_equal 280 }
      it { _(content.height).must_equal 355 }
      it { _(content.aspect_ratio).must_equal (280.0 / 355.0) }
      it { _(content.xres).must_equal 72.0 }
      it { _(content.yres).must_equal 72.0 }

      it { _(content).must_be :portrait? }
      it { _(content.portrait).must_equal true } # for use with magic attributes
      it { _(content).wont_be :landscape? }
      it { _(content.landscape).must_equal false } # for use with magic attributes

      it { _(content.format).must_equal 'png' }

      it { _(content).must_be :image? }
      it { _(content.image).must_equal true } # for use with magic attributes
      it { _(app.create('blah')).wont_be :image? }
    end

    describe 'processors that change the url' do
      before { app.configure { url_format '/:name' } }

      describe 'encode' do
        let(:thumb) { content.encode('png') }

        it { _(thumb.url).must_match(/^\/sample\.png\?.*job=\w+/) }
        it { _(thumb.format).must_equal 'png' }
        it { _(thumb.meta['format']).must_equal 'png' }
      end

      describe 'rotate' do
        let(:thumb) { content.rotate(90, format: 'png') }

        it { _(thumb.url).must_match(/^\/sample\.png\?.*job=\w+/) }
        it { _(thumb.format).must_equal 'png' }
        it { _(thumb.meta['format']).must_equal 'png' }
      end

      describe 'thumb' do
        let(:thumb) { content.thumb('100x', format: 'png') }

        it { _(thumb.url).must_match(/^\/sample\.png\?.*job=\w+/) }
        it { _(thumb.format).must_equal 'png' }
        it { _(thumb.meta['format']).must_equal 'png' }
      end
    end

    describe 'other processors' do
      describe 'encode' do
        it { _(content.encode('jpg').format).must_equal 'jpg' }
        it { _(content.encode('jpg', output_options: { Q: 1 }).format).must_equal 'jpg' }
        it { _(content.encode('jpg', output_options: { Q: 1 }).size).must_be :<, 65_000 }
      end

      describe 'extract_area' do
        it { _(content.extract_area(100, 100, 50, 200, format: 'jpg').format).must_equal 'jpg' }
        it { _(content.extract_area(100, 100, 50, 200, format: 'jpg').width).must_equal 50 }
        it { _(content.extract_area(100, 100, 50, 200, format: 'jpg').height).must_equal 200 }
      end

      describe 'rotate' do
        it { _(content.rotate(90).width).must_equal 355 }
        it { _(content.rotate(90).height).must_equal 280 }
      end
    end
  end
end
