require './app'

use Rack::Static, :urls => ["/images"], :root => "public"
run Sinatra::Application