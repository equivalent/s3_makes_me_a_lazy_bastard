module S3MakesMeALazyBastard
  module ExecutorConcern
    def local_execute(*args)
      logger.debug("Local execute: #{args.inspect}")
      out, error, status = executor.call(*args)
      raise error unless status.success?
      out
    end

    def s3_execute(*args)
      logger.debug("S3 execute: #{args.inspect}")
      out, error, status = executor.call(*args)
      raise S3CmdError, error unless status.success?
      out
    end
  end
end
