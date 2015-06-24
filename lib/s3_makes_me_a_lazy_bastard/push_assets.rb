module S3MakesMeALazyBastard
  class PushAssets
    include BucketConcern
    include FolderConcern
    include ExecutorConcern

    attr_reader :bucket_name, :source_folder

    def initialize(destination_bucket_name:,
                   source_local_folder:,
                   logger: S3MakesMeALazyBastard.config.default_logger,
                   executor: S3MakesMeALazyBastard.config.default_executor)

      @bucket_name = destination_bucket_name
      @source_folder = source_local_folder
      @logger = logger
      @executor = executor
    end

    def call
      check_folder_ducktype(source_folder)
      s3_execute(*sync_cmd)
    end

    private
      attr_reader :executor, :logger

      def sync_cmd
        ['s3cmd', 'sync', source_folder.to_s, bucket]
      end
  end
end
