class TestsController < Simpler::Controller
  def index
    @time = Time.now
    # header content_type: 'text/plain'
  end

  def create
    render plain: "Plain text response"
    status 500
  end

  def show
    @params = params[:id]
  end
end
