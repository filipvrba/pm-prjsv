module RJSV
  module Plugins
    module PackageManager
      module CLI
        module Arguments
          @options = {
            create: nil,
            install: nil,
          }

          module_function

          def init(package_manager)
            OptionParser.parse do |parser|
              parser.banner(
                "#{package_manager.description()}\n\n" +
                "Usage: #{APP_NAME} #{package_manager.name()} [options]\n" +
                "\nOptions:"
              )

              parser.on( "create", "", "Creates a package from a web project." ) do
                @options[:create] = true
              end
              parser.on( "install PACKAGE", "", "The package is installed in\n" +
                                                "the working folder." ) do |package|
                @options[:install] = package
              end

              parser.on( "-h", "--help", "Show help" ) do
                puts parser
                exit
              end
              parser.on( "-v", "--version", "Show version" ) do
                puts "Version is #{RJSV::Plugins::PackageManager::VERSION}"
                exit
              end
            end
          end

          def options
            @options
          end
        end#Arguments
      end
    end
  end
end