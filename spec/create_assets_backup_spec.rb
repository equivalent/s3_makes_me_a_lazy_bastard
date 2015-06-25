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
  let(:times_array) {  [Time.new(666), (this_time_should_be_cached = Time.new(2012, 01, 02))] }
  let(:time_generator) { ->(){ times_array.pop } }
  let(:backup_creator) { described_class.new(options) }
  let(:trigger) { backup_creator.call }

  describe 'execution of commands' do
    it 'pull assets to folder, compres and push to backup bucket' do
      should_create_folder('/tmp/my-dir/foobarbackup')

      expect(executor)
        .to receive(:call)
        .with("s3cmd", "sync", "--delete-removed",
              "s3://my-awesome-bucket", "/tmp/my-dir/foobarbackup")
        .and_return(['not important', '', double(success?: true)])

      tar = ["tar", "-zcvf",
             "/tmp/my-dir/foobarbackup_2012-01-02_1325462400.tar.gz",
             "/tmp/my-dir/foobarbackup"]
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


      # cleanup folders after successful run
      expect(executor)
        .to receive(:call)
        .with("rm", "-rf", "/tmp/my-dir/foobarbackup")
        .and_return(['not important', '', double(success?: true)])

      expect(executor)
        .to receive(:call)
        .with("rm", "-rf", "/tmp/my-dir/foobarbackup_2012-01-02_1325462400.tar.gz")
        .and_return(['not important', '', double(success?: true)])

      trigger
    end
  end
end
