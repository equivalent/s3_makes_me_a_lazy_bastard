module S3MakesMeALazyBastard
  class CreateAssetsBackup
    include BucketConcern

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
      check_folder_ducktype
      pull_source_bucket_assets
      compress
      push_assets_backup_to_destination
    end

    private
      attr_reader :timestamp_format, :executor, :time_generator

      def check_folder_ducktype
        raise 'folder must be a Pathname like object (ducktype)' unless folder.respond_to?(:join)
      end

      def pull_source_bucket_assets
        out, error, status = executor.call(*pull_asset_cmd)
        raise S3CmdError, error unless status.success?
      end

      def pull_asset_cmd
        # add --dry-run for testing
        ['s3cmd', 'sync', '--delete-removed', bucket(source_bucket_name), local_backup_folder_path.to_s]
      end

      def compress
        out, error, status = executor.call(*compress_cmd)
        raise error unless status.success?
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
        out, error, status = executor.call(*push_cmd)
        raise S3CmdError, error unless status.success?
      end

      def push_cmd
        ['s3cmd', 'put', '--recursive',  backup_path.to_s, "#{bucket(destination_bucket_name)}/#{backup_file}"]
      end

      def time_name
        time_generator.call.strftime(timestamp_format)
      end
  end
end
