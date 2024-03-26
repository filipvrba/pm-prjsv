module RJSV
  module Plugins
    module PackageManager
      module IO
        module_function

        def modify_paths(files)
          files.each do |file|
            content = RJSV::Core::Files.open(file)
            reg_find_all_imports = /^import ["']([^"']+)["']$|import ["'](.*)["'],?\s["'](.*)["']/
            fix_content = content.gsub(reg_find_all_imports) do |s|
              options = s.scan(reg_find_all_imports)[0]
              relevant_path = File.expand_path('.', file.sub('.js.rb', ''))
                              .sub(Dir.pwd, File.join('..', '..'))
              root_path = File.dirname(file)
              l_rel_path = lambda do |path|
                File.expand_path(path, root_path)
                .sub(Dir.pwd, File.join('..', '..'))
              end

              if options[0] == nil
                "import '#{options[1]}', '#{l_rel_path.call(options[2])}'"
              else
                "import '#{l_rel_path.call(options[0])}'"
              end
            end
            RJSV::Core::Files.write_with_dir(fix_content, file)
          end
        end

        def correct?(package_name)
          print "Install this '#{package_name}' package? (Y/n): "
          input = STDIN.gets.chomp
          result = true
      
          if input.downcase.index("n")
            result = false
          end
          return result
        end
      end#Hash
    end
  end
end