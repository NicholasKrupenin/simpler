require 'erb'

module Simpler
  class View
    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      template = render_option.nil? ? File.read(template_path) : another_template
      ERB.new(template).result(binding)
    end

    private

    def another_template
      @env['simpler.template.status'] = render_option
      case render_option.keys.first
      when :plain
        render_option[:plain]
      when :json
        render_option[:json].to_json
      else
        raise StandardError "Unknown render option: #{render_option.keys.first}"
      end
    end

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def render_option
      @env['simpler.render.options']
    end

    def template_path
      path = template || [controller.name, action].join('/')
      @env['simpler.template.status'] = "#{path}.html.erb"
      Simpler.root.join(VIEW_BASE_PATH, "#{path}.html.erb")
    end
  end
end
