# CHANGELOG

## 1.0.4

* `vips` is required closer to when the classes are called, in hope of fixing [#107](https://github.com/jcupitt/ruby-vips/issues/107)

## 1.0.0

* rewritten to use `ruby-vips` instead of CLI vips utils, which should result in better performance
* processors `convert`, `vips` and `vipsthumbnail` have been removed
