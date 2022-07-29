# frozen_string_literal: true

module DragonflyLibvips
  Dimensions = Struct.new(:orig_w, :orig_h, :geom_w, :geom_h, :x_offset, :y_offset, :area, :modifiers, :gravity, keyword_init: true) do
    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end

    def call
      case
        when ignore_aspect_ratio?
          OpenStruct.new(x_scale: horizontal_scale, y_scale: vertical_scale)
        when do_not_resize?
          OpenStruct.new(width: orig_w, height: orig_h, scale: 1)
        when fill_area?
          OpenStruct.new(width: geom_w, height: geom_h, scale: scale_to_fill)
        when crop?
          OpenStruct.new(width: width, height: height, x: xoffset, y: yoffset, scale: scale)
        else
          OpenStruct.new(width: width, height: height, scale: scale, resize: resize)
      end
    end

    private

    def width
      if landscape?
        dimensions_specified_by_width? ? dimensions.width : dimensions.height / aspect_ratio
      else
        dimensions_specified_by_height? ? dimensions.height / aspect_ratio : dimensions.width
      end
    end

    def height
      if landscape?
        dimensions_specified_by_width? ? dimensions.width * aspect_ratio : dimensions.height
      else
        dimensions_specified_by_height? ? dimensions.height : dimensions.width * aspect_ratio
      end
    end

    def scale
      width.to_f / orig_w
    end

    def horizontal_scale
      orig_w / geom_w
    end

    def vertical_scale
      orig_h / geom_h
    end

    def scale_to_fill
      h_scale = geom_w.to_f / orig_w
      v_scale = geom_h.to_f/ orig_h
      h_scale > v_scale ? h_scale : v_scale
    end

    def xoffset

      case gravity
        when /c/
          (orig_w - width) / 2
        when /e/
          orig_w - width
        when /w/
          0
        when /[ns]/
          (orig_w - width) / 2
        else
          x_offset
      end
    end

    def yoffset
      case gravity
        when /c/
          (orig_h - height) / 2
        when /n/
          0
        when /s/
          orig_h - height
        when /[ew]/
          (orig_h - height) / 2
        else
          y_offset
      end
    end

    def dimensions
      OpenStruct.new(width: geom_w, height: geom_h)
    end

    def aspect_ratio
      orig_h.to_f / orig_w
    end

    def dimensions_specified_by_width?
      dimensions.width.positive?
    end

    def dimensions_specified_by_height?
      dimensions.height.positive?
    end

    def landscape?
      aspect_ratio <= 1.0
    end

    def portrait?
      !landscape?
    end

    def resize
      return :down if modifiers&.include? '>'
      return :up if modifiers&.include? '>'
      return :both
    end

    def do_not_resize_if_image_smaller_than_requested?
      return false unless modifiers&.include? '>'

      orig_w < geom_w && orig_h < geom_h
    end

    def do_not_resize_if_image_larger_than_requested?
      return false unless modifiers&.include? '<'

      orig_w > geom_w && orig_h > geom_h
    end

    def do_not_resize?
      do_not_resize_if_image_smaller_than_requested? || do_not_resize_if_image_larger_than_requested?
    end

    def fill_area?
      modifiers&.include?('^')
    end

    def ignore_aspect_ratio?
      modifiers&.include?('!')
    end

    def crop?
      gravity || !(x_offset.zero? && y_offset.zero?)
    end
  end
end
