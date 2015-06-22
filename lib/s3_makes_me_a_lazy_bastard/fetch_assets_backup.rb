module S3MakesMeALazyBastard
  class FetchAssetsBackup
    include BucketConcern

    attr_reader :bucket_name, :destination_folder

    def initialize(source_bucket_name:,
                   destination_local_folder:,
                   logger: S3MakesMeALazyBastard.config.default_logger,
                   executor: S3MakesMeALazyBastard.config.default_executor)
      @bucket_name = source_bucket_name
      @destination_folder = destination_local_folder
      @logger = logger
      @executor = executor
    end

    def  call
      prepare_destination_folder
      fetch_assets_backup
      extract_assets_backup
    end

    def fetch_assets_backup
      logger.info "Fetching Latest production assets backup: #{latest_id}"
      logger.debug fetch_cmd
      out, error, status = executor.call(*fetch_cmd)
      raise S3CmdError, error unless status.success?
    end

    def extract_assets_backup
      logger.debug extract_cmd
      out, error, status = executor.call(*extract_cmd)
      raise error unless status.success?
    end

    private
      attr_reader :executor, :logger

      def fetch_cmd
        ['s3cmd', 'get', "#{bucket}/#{latest_id}", destination_file_full_path]
      end

      def destination_file_full_path
        "#{destination_folder}/#{latest_id}"
      end

      def extract_cmd
        ["tar", '-zxvf', destination_file_full_path, '-C', destination_folder]
      end

      def prepare_destination_folder
        system("mkdir #{destination_folder}")
        system("rm -rf #{destination_folder}") # rm old dump
        system("mkdir #{destination_folder}") # bacause I'm lazy that's why !!
      end

      def latest_id
        @latest_id ||= begin
          out, error, status = executor.call(*fetech_latest_backup_name_cmd)
          if status.success?
            out.split("\n").last.split('/').last
          else
            raise S3CmdError, error
          end
        end
      end

      def fetech_latest_backup_name_cmd
        ['s3cmd', 'ls', bucket]
      end
  end
end
