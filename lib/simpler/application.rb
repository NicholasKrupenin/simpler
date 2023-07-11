require 'yaml'
require 'singleton'
require 'sequel'
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
      @router.instance_eval(&block) # call block from routes.rb
    end

    def call(env)
      route = @router.route_for(env) # call route_for from router.rb
      controller = route.controller.new(env) # call controller from route.rb
      action = route.action

      make_response(controller, action) # call make_response from controller.rb
    end

    private

    def require_app
      Dir["#{Simpler.root}/app/**/*.rb"].each { |file| require file } # require each file from app folder
    end

    def require_routes
      require Simpler.root.join('config/routes') # require routes.rb ~/simpler/config/routes.rb
    end

    def setup_database
      database_config = YAML.load_file(Simpler.root.join('config/database.yml')) # load database.yml
      database_config['database'] = Simpler.root.join(database_config['database']) # set path to database
                                                      # ~/simpler/#{database_config['database']}
      @db = Sequel.connect(database_config) # connect to database with Sequel hash
    end

    def make_response(controller, action)
      controller.make_response(action)
    end
  end
end
