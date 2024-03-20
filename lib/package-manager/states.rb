module RJSV
  module Plugins
    module PackageManager
      module States
        module_function

        def install_state(options)
          install = options[:install]
          if install
            # TODO: search and download package
          end
        end
      end#States
    end
  end
end