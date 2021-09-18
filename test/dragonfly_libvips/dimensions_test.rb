require 'test_helper'
require 'dragonfly_libvips/geometry'

describe DragonflyLibvips::Dimensions do
  let(:geometry) { '' }
  let(:geometry_fields) {DragonflyLibvips::Geometry.call(geometry)}
  let(:orig_w) { nil }
  let(:orig_h) { nil }
  let(:result) { DragonflyLibvips::Dimensions.call( orig_w: orig_w, orig_h: orig_h, **geometry_fields) }

  describe 'NNxNN' do
    let(:geometry) { '250x250' }

    describe 'when square' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 1000 }

      it { result.width.must_equal 250 }
      it { result.height.must_equal 250 }
      it { result.scale.must_equal 250.0 / orig_w }

      describe '250x250>' do
        let(:geometry) { '250x250>' }

        describe 'when image larger than specified' do
          it 'resize' do
            result.width.must_equal 250
            result.height.must_equal 250
            result.scale.must_equal 250.0 / orig_w
          end
        end

        describe 'when image smaller than specified' do
          let(:orig_w) { 100 }
          let(:orig_h) { 100 }
          it 'do not resize' do
            result.width.must_equal 100
            result.height.must_equal 100
            result.scale.must_equal 100.0 / orig_w
          end
        end
      end

      describe '250x50<' do
        let(:geometry) { '250x250<' }

        describe 'when image larger than specified' do
          it 'do not resize' do
            result.width.must_equal 1000
            result.height.must_equal 1000
            result.scale.must_equal 1000.0 / orig_w
          end
        end

        describe 'when image smaller than specified' do
          let(:orig_w) { 100 }
          let(:orig_h) { 100 }

          it 'do resize' do
            _(result.width).must_equal 250
            _(result.height).must_equal 250
            _(result.scale).must_equal 250.0 / orig_w
          end
        end
      end
    end

    describe 'when landscape' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 500 }

      it { _(result.width).must_equal 250 }
      it { _(result.height).must_equal 125 }
      it { _(result.scale).must_equal 250.0 / orig_w }
    end

    describe 'when portrait' do
      let(:orig_w) { 500 }
      let(:orig_h) { 1000 }

      it { _(result.width).must_equal 125 }
      it { _(result.height).must_equal 250 }
      it { _(result.scale).must_equal 125.0 / orig_w }
    end
  end

  describe 'NNx' do
    let(:geometry) { '250x' }

    describe 'when square' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 1000 }

      it { _(result.width).must_equal 250 }
      it { _(result.height).must_equal 250 }
      it { _(result.scale).must_equal 250.0 / orig_w }
    end

    describe 'when landscape' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 500 }

      it { _(result.width).must_equal 250 }
      it { _(result.height).must_equal 125 }
      it { _(result.scale).must_equal 250.0 / orig_w }
    end

    describe 'when portrait' do
      let(:orig_w) { 500 }
      let(:orig_h) { 1000 }

      it { _(result.width).must_equal 250 }
      it { _(result.height).must_equal 500 }
      it { _(result.scale).must_equal 250.0 / orig_w }
    end
  end

  describe 'xNN' do
    let(:geometry) { 'x250' }

    describe 'when square' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 1000 }

      it { _(result.width).must_equal 250 }
      it { _(result.height).must_equal 250 }
      it { _(result.scale).must_equal 250.0 / orig_w }
    end

    describe 'when landscape' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 500 }

      it { _(result.width).must_equal 500 }
      it { _(result.height).must_equal 250 }
      it { _(result.scale).must_equal 500.0 / orig_w }
    end

    describe 'when portrait' do
      let(:orig_w) { 500 }
      let(:orig_h) { 1000 }

      it { _(result.width).must_equal 125 }
      it { _(result.height).must_equal 250 }
      it { _(result.scale).must_equal 125.0 / orig_w }
    end
  end

  describe 'NNxMM!' do
    let(:geometry) {'200x100!'}

    describe 'when square' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 1000 }

      it { _(result.width).must_equal 200 }
      it { _(result.height).must_equal 100 }
    end
  end

  describe 'offsets' do
    let(:orig_w) { 1000 }
    let(:orig_h) { 1000 }

    describe 'with x offset' do
      let(:geometry) {'200x200+50+0'}

      it {_(result.x).must_equal 450}
      it {_(result.y).must_equal 400}
    end

    describe 'with y offset' do
      let(:geometry) {'200x200+0+50'}

      it {_(result.x).must_equal 400 }
      it {_(result.y).must_equal 450}
    end
  end

  describe 'gravity' do
    let(:orig_w) { 1000 }
    let(:orig_h) { 1000 }

    describe 'centre' do
      let(:geometry) {'200x200#c'}

      it { _(result.x).must_equal 400 }
      it { _(result.y).must_equal 400 }
    end

    describe 'north' do
      let(:geometry) {'200x200#n'}

      it { _(result.x).must_equal 400 }
      it { _(result.y).must_equal 0 }
    end

    describe 'west' do
      let(:geometry) {'200x200#w'}

      it { _(result.x).must_equal 0 }
      it { _(result.y).must_equal 400 }
    end

    describe 'north east' do
      let(:geometry) {'200x200#ne'}

      it { _(result.x).must_equal 800 }
      it { _(result.y).must_equal 0 }
    end

    describe 'south west' do
      let(:geometry) {'200x200#sw'}

      it { _(result.x).must_equal 0 }
      it { _(result.y).must_equal 800 }
    end
  end
end
