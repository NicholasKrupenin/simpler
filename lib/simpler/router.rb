require_relative 'router/route'

module Simpler
  class Router
    def initialize
      @routes = []
    end

    def get(path, route_point)
      add_route(:get, path, route_point)
    end

    def post(path, route_point)
      add_route(:post, path, route_point)
    end

    def route_for(env)
      method = env['REQUEST_METHOD'].downcase.to_sym # get request method
      path = env['PATH_INFO'] # get path
      found_route = @routes.find { |route| route.match?(method, path) }# find match route in route.rb (only one)
      raise NoMethodError, "No route for #{method} #{path}" unless found_route # raise error if route not found
      found_route&.extract_params(path) # merge params from route.rb
      found_route
    end

    private

    def add_route(method, path, route_point)
      route_point = route_point.split('#')
      controller = controller_from_string(route_point[0]) # get controller constant
      action = route_point[1]
      route = Route.new(method, path, controller, action)

      @routes.push(route) # collect all routes in array
    end

    def controller_from_string(controller_name)
      Object.const_get("#{controller_name.capitalize}Controller") # get controller constant in scope
    end
  end
end
