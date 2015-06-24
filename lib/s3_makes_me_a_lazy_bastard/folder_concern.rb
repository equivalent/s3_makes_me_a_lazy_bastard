module S3MakesMeALazyBastard
  module FolderConcern
    def prepare_folder(destination_folder)
      mkdir_cmd = ['mkdir', '-p', destination_folder.to_s]
      if S3MakesMeALazyBastard.config.rm_old_dump_on_lunch
        logger.info "Cleaning folder #{destination_folder}"
        local_execute(*mkdir_cmd) # bacause I'm lazy that's why !!
        delete_local_file(destination_folder)
      end
      logger.info "Init folder #{destination_folder}"
      local_execute(*mkdir_cmd)
    end

    # in ideal OO design I don't have to do this but
    # I want to ensure Pathname like object is used to avoid
    # some destructive operations happening
    def check_folder_ducktype(folder)
      raise 'folder must be a Pathname like object (ducktype)' unless folder.respond_to?(:join)
    end

    def delete_local_file(folder)
      local_execute(*['rm', '-rf', folder.to_s]) # rm old dump
    end
  end
end
