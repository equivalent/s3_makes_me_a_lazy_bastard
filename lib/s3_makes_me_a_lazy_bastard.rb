require 'pathname'
require 'logger'
require 'open3'
require "s3_makes_me_a_lazy_bastard/version"
require "s3_makes_me_a_lazy_bastard/bucket_concern"
require "s3_makes_me_a_lazy_bastard/folder_concern"
require "s3_makes_me_a_lazy_bastard/executor_concern"
require "s3_makes_me_a_lazy_bastard/create_assets_backup"
require "s3_makes_me_a_lazy_bastard/fetch_assets_backup"
require "s3_makes_me_a_lazy_bastard/push_assets"

module S3MakesMeALazyBastard
  S3CmdError = Class.new(StandardError)

  class Configuration
    attr_writer :default_executor, :default_logger, :default_timestamp_format,
      :time_generator, :rm_old_dump_on_lunch, :rm_local_folder_when_finished

    def rm_local_folder_when_finished
      @rm_local_folder_when_finished ||= true
    end

    def rm_old_dump_on_lunch
      @rm_old_dump_on_lunch ||= true
    end

    def default_logger
      @default_logger ||= Logger.new(STDOUT)
    end

    # object that responds to #call
    def default_executor
      @default_executor = ->(*cmd) { Open3.capture3 *cmd }
    end

    def default_timestamp_format
      "%Y-%m-%d_%s"
    end

    def default_time_generator
      ->() { Time.now }
    end
  end

  def self.config
    @config ||= Configuration.new
  end
end
