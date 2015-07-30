require "http/server"

require "./startram/*"

module Startram
  class App < HTTP::Handler
    getter router

    def initialize
      @router = Router.new
    end

    def call(request)
      request = Request.new(request)

      if route = router.match(request.method, request.path)
        route.call(request).to_http_response
      else
        HTTP::Response.not_found
      end
    end

    def handlers
      [
        HTTP::LogHandler.new
        HTTP::ErrorHandler.new
        self
      ]
    end

    def serve
      port = ENV["PORT"]? || 7777
      server = HTTP::Server.new(port.to_i, handlers)
      puts "Listening to http://localhost:#{port}"
      server.listen
    end
  end
end
