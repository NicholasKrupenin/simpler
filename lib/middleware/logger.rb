require 'logger'

class AppLogger
  HTTP_CODE_STATUS = {
    '200' => 'OK',
    '404' => 'Not Found',
    '429' => 'Resource',
    '500' => 'Internal Server Error'
    # etc
  }.freeze

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
    "#{@env['simpler.controller'].class}##{@env['simpler.action']}"
  end

  def params_logger
    @env['simpler.params']
  end

  def response_logger
    status = @env['simpler.status']
    headers = @env['simpler.headers']
    template = @env['simpler.template']

    #"#{status} [#{HTTP_CODE_STATUS[status.to_s]}] [#{headers["Content-Type"]}] [#{template}]"
  end
end
