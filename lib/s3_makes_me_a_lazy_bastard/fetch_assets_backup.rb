module S3MakesMeALazyBastard
  class FetchAssetsBackup
    include BucketConcern
    include FolderConcern
    include ExecutorConcern

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
      check_folder_ducktype(destination_folder)
      prepare_folder(destination_folder)
      fetch_assets_backup
      extract_assets_backup
    end

    def fetch_assets_backup
      logger.info "Fetching Latest production assets backup: #{latest_id}"
      s3_execute(*fetch_cmd)
    end

    def extract_assets_backup
      logger.info "Extracting #{destination_file_full_path} to #{destination_folder}"
      local_execute(*extract_cmd)
    end

    private
      attr_reader :executor, :logger

      def fetch_cmd
        ['s3cmd', 'get', "#{bucket}/#{latest_id}", destination_file_full_path.to_s]
      end

      def destination_file_full_path
        destination_folder.join(latest_id)
      end

      def extract_cmd
        ["tar", '-zxvf', destination_file_full_path.to_s, '-C', destination_folder.to_s]
      end

      def latest_id
        @latest_id ||= begin
          out = s3_execute(*fetech_latest_backup_name_cmd)
          out.split("\n").last.split('/').last
        end
      end

      def fetech_latest_backup_name_cmd
        ['s3cmd', 'ls', bucket]
      end
  end
end
