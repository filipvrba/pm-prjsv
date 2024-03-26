module RJSV
  module Plugins
    module PackageManager
      module States
        module_function

        def create_state(options)
          create = options[:create]
          unless create
            return
          end
            
          package_path = File.join(Dir.pwd, 'package.json')
          package_json = JsonParser.new package_path

          name    = package_json.parse(:name)
          version = package_json.parse(:version)
          files   = package_json.parse(:files)
          unless name and version and files
            RJSV::Core::Event.print('json',
            "Unable to read the project's package.json file " +
            "to get the information.")
            return
          end

          files = Dir.glob(files.split(',').map(&:strip))
          hash = PackageManager::Hash.encode([name, version], files)
          hash_path = PackageManager::Hash.get_hash_path(name, version)

          RJSV::Core::Files.write_with_dir(hash, hash_path)
          RJSV::Core::Event.print('create',
            "The '#{File.basename(hash_path, '.*')}' package was created.")
        end

        def install_state(options)
          install = options[:install]
          if install
            file = PackageManager::Hash.filter_out(install)
            unless file
              return
            end

            unless PackageManager::IO.correct?(File.basename(file, '.*'))
              return
            end

            output_dir = PackageManager::Hash.decode(file)
            RJSV::Core::Event.print('install',
              "Package extracted to '#{output_dir.sub(Dir.pwd(), '.')}'.")

            output_path_files = File.join(output_dir, 'src', 'rb', '**', '*.rb')
            output_files = Dir.glob(output_path_files)
            PackageManager::IO.modify_paths(output_files)
            RJSV::Core::Event.print('install', "Relevant paths have been changed.")

            output_dir_relevant = output_dir.sub(File.join(Dir.pwd(), ''), '')
            path_file_elements = File.join(output_dir, 'src', 'rb', 'elements.js.rb')
            is_file_elements_exist = File.exist?(path_file_elements)
            if is_file_elements_exist
              rel_path_elements = File.join('src', 'rb', 'elements.js.rb')
              RJSV::Core::Files.write_with_dir(
                "\nimport '#{File.join('..', '..', output_dir_relevant, 'src', 'js', 'elements')}'\n",
                File.join(Dir.pwd(), rel_path_elements),
                'a+'
              )
              RJSV::Core::Event.print('install',
                "An element was discovered and credited as an import to '#{rel_path_elements}'.")
            end

            RJSV::Core::Event.print('install', "The rb files are being translated...")

            options_translate = {
              translate: true,
              source: File.join(output_dir, 'src', 'rb'),
              output: File.join(output_dir, 'src', 'js')
            }
            files_rb = RJSV::Core::Files.find_all(options_translate[:source])
            files_rb.each do |path|
              RJSV::CLI::States.translate_state(path, options_translate)
            end
          end
        end
      end#States
    end
  end
end