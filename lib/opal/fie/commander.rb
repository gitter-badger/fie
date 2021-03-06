require 'fie/native'
require 'diffhtml'

module Fie
  class Commander < Fie::Native::ActionCableChannel
    include Fie::Native

    def connected
      super

      @cable.call_remote_function \
        element: Element.body,
        function_name: 'initialize_state',
        event_name: 'Upload State',
        parameters: { view_variables: Util.view_variables }
    end

    def received(data)
      process_command(data['command'], data['parameters'])
    end

    def process_command(command, parameters = {})
      case command
      when 'refresh_view'
        puts parameters['html']
        $$.diff.innerHTML(Element.fie_body.unwrapped_element, parameters['html'])
      when 'subscribe_to_pools'
        parameters['subjects'].each do |subject|
          @cable.subscribe_to_pool(subject)
        end
      when 'publish_to_pools'
        subject = parameters['subject']
        object = parameters['object']

        perform("pool_#{ subject }_callback", { object: object })
      when 'execute_function'
        Util.exec_js(parameters['name'], parameters['arguments'])
      else
        console.log("Command: #{ command }, Parameters: #{ parameters }")
      end
    end
  end
end
