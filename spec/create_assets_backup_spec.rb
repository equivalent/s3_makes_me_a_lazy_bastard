require 'spec_helper'

RSpec.describe S3MakesMeALazyBastard::CreateAssetsBackup do

  let(:options) { {
    source_bucket_name: 'my-awesome-bucket',
    destination_bucket_name: 'my-bucket-backup',
    transient_local_folder: Pathname.new('/tmp/my-dir'),
    backup_name: 'foobarbackup',
    logger: logger,
    executor: executor,
    time_generator: time_generator,
    timestamp_format: S3MakesMeALazyBastard.config.default_timestamp_format
  }}

  let(:logger) { spy }
  let(:executor) { double }
  let(:time_generator) { ->(){ Time.new(2012, 01, 02) } }
  let(:backup_creator) { described_class.new(options) }
  let(:trigger) { backup_creator.call }

  it do
    expect(executor)
      .to receive(:call)
      .with("s3cmd", "sync", "--delete-removed",
            "s3://my-awesome-bucket", "/tmp/my-dir/foobarbackup")
      .and_return(['not important', '', double(success?: true)])

    tar = ["tar", "-zcvf", "/tmp/my-dir/foobarbackup",
           "/tmp/my-dir/foobarbackup_2012-01-02_1325462400.tar.gz"]
    expect(executor)
      .to receive(:call)
      .with(*tar)
      .and_return(['not important', '', double(success?: true)])

    s3upload = ["s3cmd", "put", "--recursive",
                "/tmp/my-dir/foobarbackup_2012-01-02_1325462400.tar.gz",
                "s3://my-bucket-backup/foobarbackup_2012-01-02_1325462400.tar.gz"]
    expect(executor)
      .to receive(:call)
      .with(*s3upload)
      .and_return(['not important', '', double(success?: true)])

    trigger
  end
end
