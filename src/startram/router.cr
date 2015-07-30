module Startram
  class Router
    HTTP_METHODS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS TRACE]

    def initialize
      @routes = {} of String => Array(Route)

      HTTP_METHODS.each do |method|
        @routes[method] = [] of Route
      end
    end

    {% for method in HTTP_METHODS %}
      def {{method.id.downcase}}(path, controller_class, action)
        @routes[{{method}}] << Route.new(path, controller_class, action)
      end

      def {{method.id.downcase}}(path, &block : Request -> Response)
        @routes[{{method}}] << Route.new(path, &block)
      end
    {% end %}

    def draw
      with self yield
    end

    def match(method, path)
      @routes[method].find &.match?(path)
    end
  end
end