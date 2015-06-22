require 'spec_helper'

RSpec.describe S3MakesMeALazyBastard::FetchAssetsBackup do

  let(:options) {
    {
      source_bucket_name: 'my-awesome-bucket',
      destination_local_folder: '/tmp/assets-from-my-awesome-bucket',
      executor: executor,
      logger: logger
    }
  }

  let(:asset_fetcher) { described_class.new(options) }
  let(:trigger) { asset_fetcher.call }

  let(:s3_ls_out) { "uploads/2015-06-21-foo.tar.gz\nuploads/2015-06-22-bar.tar.gz" }

  describe 'execution of commands' do
    let(:logger) { spy }
    let(:executor) { double :executor }

    it 'it should dowload leatest asset backp and extract it' do
      expect(executor)
        .to receive(:call)
        .with("s3cmd", "ls", "s3://my-awesome-bucket")
        .and_return([s3_ls_out, nil, double(success?: true) ])

      expect(executor)
        .to receive(:call)
        .with("s3cmd", "get", "s3://my-awesome-bucket/2015-06-22-bar.tar.gz",
           "/tmp/assets-from-my-awesome-bucket/2015-06-22-bar.tar.gz")
        .and_return(['not important', nil, double(success?: true) ])

      expect(executor)
        .to receive(:call)
        .with("tar", "-zxvf", "/tmp/assets-from-my-awesome-bucket/2015-06-22-bar.tar.gz",
          "-C", "/tmp/assets-from-my-awesome-bucket")
        .and_return(['not important', nil, double(success?: true) ])

      trigger
    end

    context 'when s3 ls throws error' do
      it do
        expect(executor)
          .to receive(:call)
          .with("s3cmd", "ls", "s3://my-awesome-bucket")
          .and_return([s3_ls_out, 's3 ls error', double(success?: false) ])

        expect { trigger }.to raise_error S3MakesMeALazyBastard::S3CmdError, 's3 ls error'
      end
    end
  end
end
