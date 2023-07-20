require 'yaml'
require 'singleton'
require 'sequel'
require 'pry'
require_relative 'router'
require_relative 'controller'

module Simpler
  class Application
    include Singleton

    attr_reader :db

    def initialize
      @router = Router.new
      @db = nil
    end

    def bootstrap!
      setup_database
      require_app
      require_routes
    end

    def routes(&block)
      @router.instance_eval(&block)
    end

    def call(env)
      @env = env
      route = @router.route_for(env)
      controller = route.controller.new(env)
      route.merge_params(controller) if route.path.is_a?(Regexp)
      action = route.action
      make_response(controller, action)
    rescue StandardError => e
      error = Rack::Response.new("#{e.message}", 404, { 'Content-Type' => 'text/plain' })
      @env['simpler.error'] = error
      error.finish
    end

    private

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file }
    end

    def require_routes
      require Simpler.root.join('config/routes')
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml'))
      database_config['database'] = Simpler.root.join(database_config['database'])
      @db = Sequel.connect(database_config)
    end

    def make_response(controller, action)
      controller.make_response(action)
    end
  end
end
