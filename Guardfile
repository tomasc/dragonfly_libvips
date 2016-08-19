# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :minitest do
  watch(%r{^lib/(.+)\.rb$})                               { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/test_helper\.rb$})                       { 'test' }
end
