require 'test_helper'

module DragonflyLibvips
  describe Plugin do
    let(:app) { test_app.configure_with(:libvips) }
    let(:image) { app.fetch_file(SAMPLES_DIR.join('beach.png')) }

    describe 'env variables' do
      let(:app) { test_app }

      it 'allows setting the vips command' do
        app.configure { plugin :libvips, vips_command: '/bin/vips' }
        app.env[:vips_command].must_equal '/bin/vips'
      end

      it 'allows setting the vipsheader command' do
        app.configure { plugin :libvips, vipsheader_command: '/bin/vipsheader' }
        app.env[:vipsheader_command].must_equal '/bin/vipsheader'
      end

      it 'allows setting the vipsthumbnail command' do
        app.configure { plugin :libvips, vipsthumbnail_command: '/bin/vipsthumbnail' }
        app.env[:vipsthumbnail_command].must_equal '/bin/vipsthumbnail'
      end
    end

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
        image.portrait.must_equal true # for using with magic attributes
      end

      it "says if it's landscape" do
        image.landscape?.must_equal false
        image.landscape.must_equal false # for using with magic attributes
      end

      it 'returns the format' do
        image.format.must_equal 'png'
      end

      it "says if it's an image" do
        image.image?.must_equal true
        image.image.must_equal true # for using with magic attributes
      end

      it "says if it's not an image" do
        app.create('blah').image?.must_equal false
      end
    end

    describe 'processors that change the url' do
      before do
        app.configure { url_format '/:name' }
      end

      describe 'convert' do
        it 'sanity check with format' do
          thumb = image.vips('resize', '0.5', 'format' => 'jpg')
          thumb.url.must_match(/^\/beach\.jpg\?.*job=\w+/)
          thumb.width.must_equal 140
          thumb.format.must_equal 'jpeg'
          thumb.meta['format'].must_equal 'jpg'
        end

        it 'sanity check without format' do
          thumb = image.vips('resize', '0.5')
          thumb.url.must_match(/^\/beach\.png\?.*job=\w+/)
          thumb.width.must_equal 140
          thumb.format.must_equal 'png'
          thumb.meta['format'].must_be_nil
        end
      end

      describe 'encode' do
        it 'sanity check' do
          thumb = image.encode('jpg')
          thumb.url.must_match(/^\/beach\.jpg\?.*job=\w+/)
          thumb.format.must_equal 'jpeg'
          thumb.meta['format'].must_equal 'jpg'
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
          image.encode!('jpg', 'Q=1')
          image.format.must_equal 'jpeg'
          image.size.must_be :<, 3000
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

    describe 'vipsheader' do
      it 'gives the output of the command line' do
        image.vipsheader.must_match(/280/)
        image.vipsheader('-f filename').must_include 'beach.png'
      end
    end
  end
end
