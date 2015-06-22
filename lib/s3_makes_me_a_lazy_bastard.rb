require "s3_makes_me_a_lazy_bastard/version"
require "s3_makes_me_a_lazy_bastard/bucket_concern"
require "s3_makes_me_a_lazy_bastard/fetch_assets_backup"
require "s3_makes_me_a_lazy_bastard/push_assets"

module S3MakesMeALazyBastard
  S3CmdError = Class.new(StandardError)

  class Configuration
    attr_writer :default_executor, :default_logger

    def default_logger
      @default_logger ||= Logger.new(STDOUT)
    end

    # object that responds to #call
    def default_executor
      @default_executor = ->(cmd) { Open3.capture3 cmd }
    end
  end

  def self.config
    @config ||= Configuration.new
  end
end
