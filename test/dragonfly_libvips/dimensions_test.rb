require 'test_helper'

describe DragonflyLibvips::Dimensions do
  let(:dimensions) { '' }
  let(:orig_w) { nil }
  let(:orig_h) { nil }
  let(:result) { DragonflyLibvips::Dimensions.call(dimensions, orig_w, orig_h) }

  # ---------------------------------------------------------------------

  describe 'NNxNN' do
    let(:dimensions) { '250x250' }

    describe 'when square' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 1000 }

      it { result.width.must_equal 250 }
      it { result.height.must_equal 250 }
      it { result.scale.must_equal 250.0 / orig_w }

      describe '250x250>' do
        let(:dimensions) { '250x250>' }

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
        let(:dimensions) { '250x250<' }

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
            result.width.must_equal 250
            result.height.must_equal 250
            result.scale.must_equal 250.0 / orig_w
          end
        end
      end
    end

    describe 'when landscape' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 500 }

      it { result.width.must_equal 250 }
      it { result.height.must_equal 125 }
      it { result.scale.must_equal 250.0 / orig_w }
    end

    describe 'when portrait' do
      let(:orig_w) { 500 }
      let(:orig_h) { 1000 }

      it { result.width.must_equal 125 }
      it { result.height.must_equal 250 }
      it { result.scale.must_equal 125.0 / orig_w }
    end
  end

  # ---------------------------------------------------------------------

  describe 'NNx' do
    let(:dimensions) { '250x' }

    describe 'when square' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 1000 }

      it { result.width.must_equal 250 }
      it { result.height.must_equal 250 }
      it { result.scale.must_equal 250.0 / orig_w }
    end

    describe 'when landscape' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 500 }

      it { result.width.must_equal 250 }
      it { result.height.must_equal 125 }
      it { result.scale.must_equal 250.0 / orig_w }
    end

    describe 'when portrait' do
      let(:orig_w) { 500 }
      let(:orig_h) { 1000 }

      it { result.width.must_equal 250 }
      it { result.height.must_equal 500 }
      it { result.scale.must_equal 250.0 / orig_w }
    end
  end

  # ---------------------------------------------------------------------

  describe 'xNN' do
    let(:dimensions) { 'x250' }

    describe 'when square' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 1000 }

      it { result.width.must_equal 250 }
      it { result.height.must_equal 250 }
      it { result.scale.must_equal 250.0 / orig_w }
    end

    describe 'when landscape' do
      let(:orig_w) { 1000 }
      let(:orig_h) { 500 }

      it { result.width.must_equal 500 }
      it { result.height.must_equal 250 }
      it { result.scale.must_equal 500.0 / orig_w }
    end

    describe 'when portrait' do
      let(:orig_w) { 500 }
      let(:orig_h) { 1000 }

      it { result.width.must_equal 125 }
      it { result.height.must_equal 250 }
      it { result.scale.must_equal 125.0 / orig_w }
    end
  end
end
