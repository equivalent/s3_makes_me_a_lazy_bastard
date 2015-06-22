module S3MakesMeALazyBastard
  module BucketConcern

    def bucket(explicit_bucket_name=nil)
      "s3://#{explicit_bucket_name || bucket_name}"
    end
  end
end
