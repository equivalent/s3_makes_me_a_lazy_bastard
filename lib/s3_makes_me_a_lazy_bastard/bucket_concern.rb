module S3MakesMeALazyBastard
  module BucketConcern

    def bucket
      "s3://#{bucket_name}"
    end
  end
end
