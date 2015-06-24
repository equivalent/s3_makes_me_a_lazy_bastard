module S3MakesMeALazyBastard
  class CreateAssetsBackup
    include BucketConcern
    include FolderConcern
    include ExecutorConcern

    attr_reader :bucket_name, :folder, :source_bucket_name, :destination_bucket_name, :backup_name

    def initialize(source_bucket_name:,
                   destination_bucket_name:,
                   transient_local_folder:,
                   backup_name:,
                   logger: S3MakesMeALazyBastard.config.default_logger,
                   executor: S3MakesMeALazyBastard.config.default_executor,
                   time_generator: S3MakesMeALazyBastard.config.default_time_generator,
                   timestamp_format: S3MakesMeALazyBastard.config.default_timestamp_format)
      @source_bucket_name = source_bucket_name
      @destination_bucket_name = destination_bucket_name
      @backup_name = backup_name
      @folder = transient_local_folder
      @logger = logger
      @executor = executor
      @time_generator = time_generator
      @timestamp_format = timestamp_format
    end

    def  call
      check_folder_ducktype(folder)
      prepare_folder(folder)
      pull_source_bucket_assets
      compress
      push_assets_backup_to_destination
    end

    private
      attr_reader :timestamp_format, :executor, :time_generator

      def pull_source_bucket_assets
        s3_execute(*pull_asset_cmd)
      end

      def pull_asset_cmd
        # add --dry-run for testing
        ['s3cmd', 'sync', '--delete-removed', bucket(source_bucket_name), local_backup_folder_path.to_s]
      end

      def compress
        local_execute(*compress_cmd)
      end

      def compress_cmd
        ['tar', '-zcvf',  local_backup_folder_path.to_s, backup_path.to_s]
      end

      def local_backup_folder_path
        folder.join(backup_name)
      end

      def backup_path
        folder.join(backup_file)
      end

      def backup_file
        "#{backup_name}_#{time_name}.tar.gz"
      end

      def push_assets_backup_to_destination
        s3_execute(*push_cmd)
      end

      def push_cmd
        ['s3cmd', 'put', '--recursive',  backup_path.to_s, "#{bucket(destination_bucket_name)}/#{backup_file}"]
      end

      def time_name
        time_generator.call.strftime(timestamp_format)
      end
  end
end
