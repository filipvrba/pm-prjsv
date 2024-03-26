module RJSV
  module Plugins
    module PackageManager
      module Hash
        require "base64"
        require 'securerandom'
        require 'fileutils'

        module_function

        FILE_TYPE = 'tgzb'

        def filter_out(name, files = get_files())
          files_filter = []
          files.each do |file|
            file_name = File.basename(file)
            if file_name.index(/#{name}/)
              files_filter << file
            end
          end

          files_filter.reverse.last
        end

        def get_files
          path = File.dirname get_hash_path(nil, nil)
          Dir.glob File.join(path, "*.#{FILE_TYPE}")
        end

        def get_hash_name(name, version)
          "#{name}-#{version}.#{FILE_TYPE}"  # tar + gunzip + base64
        end

        def get_hash_path(name, version)
          hash_file = get_hash_name(name, version)
          File.expand_path(
            File.join('..', '..', '..', 'share', 'packages', hash_file),
            __FILE__
          )
        end

        def tar_path(options)
          name    = options[0]
          version = options[1]

          file_name = "#{name}_#{version}"
          file_name_uniq_gz = file_name.concat("-#{SecureRandom.uuid}.tar.gz")
          File.join('', 'tmp', file_name_uniq_gz)
        end

        def encode(file, files)
          file_path_gz = tar_path(file)

          # Files for create tar.
          is_created = system("tar -czf #{file_path_gz} #{files.join(' ')}")
          unless is_created
            return
          end

          b_content = File.open(file_path_gz, 'rb') { |f| f.read }
          File.delete(file_path_gz)
          Base64.encode64(b_content)
        end

        def decode(file)
          hash = RJSV::Core::Files.open(file)

          unless hash
            return
          end

          b_content    = Base64.decode64(hash)
          options      = File.basename(file).scan(/(.*)-(\d.\d.\d)/)[0]
          file_path_gz = tar_path(options)

          File.binwrite(file_path_gz, b_content)
          output_dir = File.join(Dir.pwd, 'rjsv_modules', File.basename(file, '.*'))

          unless Dir.exist?(output_dir)
            FileUtils.mkdir_p output_dir
          end

          is_extracted = system("tar -xzf #{file_path_gz} -C #{output_dir}")
          File.delete(file_path_gz)

          return output_dir
        end
      end
    end
  end
end