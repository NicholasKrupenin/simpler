require 'logger'

class AppLogger
  def initialize(app, **options)
    @logger = Logger.new(options[:logdev], formatter: method(:log_struct))
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    @env = env
    @logger.info
    [status, headers, response]
  end

  def log_struct(_severity, datetime, _progname, _msg)
    "#{datetime}\n" \
    "Request: #{request_logger}\n" \
    "Handler: #{hadler_logger}\n" \
    "Parameters: #{params_logger}\n" \
    "Response: #{response_logger}\n" \
    "\n"
  end

  def request_logger
    "#{@env['REQUEST_METHOD']} #{@env['REQUEST_URI']}"
  end

  def hadler_logger
    if @env['simpler.controller']
      "#{@env['simpler.controller'].class}##{@env['simpler.action']}"
    else
      ''
    end
  end

  def params_logger
    if @env['simpler.request']
      @env['simpler.request'].params
    else
      {}
    end
  end

  def response_logger
    response = @env['simpler.reponse'] || @env['simpler.error']
    template = @env['simpler.template.status'] || @env['simpler.error'].body

    status = response.status
    headers = response.headers['Content-Type']
    code_status = Rack::Utils::HTTP_STATUS_CODES[status]

    "#{status} #{code_status} [#{headers}] #{template}"
  end
end
