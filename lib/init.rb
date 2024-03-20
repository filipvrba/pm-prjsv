module RJSV
  module Plugins
    module PackageManager
      require_relative './package-manager/version'
      require_relative './package-manager/cli/arguments'

      require_relative './package-manager/states'

      class Init < RJSV::Plugin
        def initialize
          @arguments_cli = RJSV::Plugins::PackageManager::CLI::Arguments
        end

        def name
          "packages"
        end

        def description
          "It is a package manager that can\n" +
          "install packages for projects."
        end

        def arguments
          @arguments_cli.init(self)
        end

        def init()
          PackageManager::States.install_state(@arguments_cli.options)
        end
      end#Init
    end
  end
end