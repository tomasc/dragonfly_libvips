$VERBOSE = nil
# added to suppress warnings about method definitions
#
require 'bundler/setup'
require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/spec'
require 'minitest/pride'
require 'dragonfly_libvips'

SAMPLES_DIR = Pathname.new(File.expand_path('../../samples', __FILE__))
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

# suppress copious warnings
# warning: method redefined; discarding old <method>
# warning: previous definition of <method> was here
# warning: instance variable @tempfile not initialized
$VERBOSE = nil

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

def test_app(name = nil)
  Dragonfly::App.instance(name).tap do |app|
    app.datastore = Dragonfly::MemoryDataStore.new
    app.secret = 'test secret'
  end
end

def test_libvips_app
  test_app.configure do
    plugin :libvips
  end
end

