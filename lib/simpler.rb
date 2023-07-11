require 'pathname'
require_relative 'simpler/application'

module Simpler
  class << self
    def application
      Application.instance # call singleton_class (new dont work here, cause it private)
    end

    def root
      Pathname.new(File.expand_path('..', __dir__)) # pathname current dir ../ (simpler)
    end
  end
end
