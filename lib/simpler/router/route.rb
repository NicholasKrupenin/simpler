module Simpler
  class Router
    class Route
      attr_reader :controller, :action, :params

      def initialize(method, path, controller, action)
        @method = method
        @path = path_dispatch(path)
        @controller = controller
        @action = action
        @params = []
      end

      def match?(method, path)
        @method == method && path.match(@path)
      end

      def extract_params(path)
        @params = Array(path.match(@path)&.named_captures).first
      end

      def merge_params(controller)
        k, v = *@params
        controller.request.update_param(k.to_sym, v)
      end

      private

      def path_dispatch(path)
        if path.match(/:\w+/)
          Regexp.new(path.gsub(/:(\w+)/, '(?<\1>\w+)'))
        else
          path
        end
      end
    end
  end
end
