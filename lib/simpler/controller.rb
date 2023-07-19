require_relative 'view'

module Simpler
  class Controller
    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action # example index

      set_default_headers
      send(action)
      write_response
      make_log
      @response.finish
    end

    private

    def make_log
      @request.env['simpler.status'] = @response.status
      @request.env['simpler.headers'] = @response.headers
      @request.env['simpler.params'] = @request.params
      @request.env['simpler.template'] = @request.env['simpler.template'] || @request.env['simpler.render.opions']
    end

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase # get name controller
    end

    def set_default_headers
      @response['ensureensureContent-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def render(options)
      if options.is_a?(Hash)
        @request.env['simpler.render.opions'] = options
      else
        @request.env['simpler.template'] = options
      end
    end

    def status(code)
      response.status = code
    end

    def header(options)
      options.transform_keys!(&method(:conversion_name))
      response.headers.merge!(options)
    end

    def conversion_name(name)
      name.to_s.split('_').map(&:capitalize).join('-')
    end
  end
end
