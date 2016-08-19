require 'bundler/setup'

require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'

require 'dragonfly'
require 'dragonfly_libvips'

# ---------------------------------------------------------------------

SAMPLES_DIR = Pathname.new(File.expand_path('../../samples', __FILE__))

# ---------------------------------------------------------------------

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# ---------------------------------------------------------------------

def test_app(name = nil)
  app = Dragonfly::App.instance(name)
  app.datastore = Dragonfly::MemoryDataStore.new
  app.secret = 'test secret'
  app
end

def test_libvips_app
  test_app.configure do
    plugin :libvips
  end
end
