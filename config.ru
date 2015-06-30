require './showbot_web'

use Rack::Deflater
run ShowbotWeb.new
