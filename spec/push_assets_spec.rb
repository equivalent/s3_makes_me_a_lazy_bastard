require 'spec_helper'

RSpec.describe S3MakesMeALazyBastard::PushAssets do

  let(:options) {
    {
      destination_bucket_name: 'my-awesome-bucket-staging',
      source_local_folder: Pathname.new('/tmp/assets-from-my-awesome-bucket/uploads'),
      logger: logger,
      executor: executor
    }
  }

  let(:asset_fetcher) { described_class.new(options) }
  let(:trigger) { asset_fetcher.call }

  describe 'execution of commands' do
    let(:logger) { spy }
    let(:executor) { double :executor }

    it 'should trigger sync assets to bucket' do
      expect(executor)
        .to receive(:call)
        .with("s3cmd", "sync", "/tmp/assets-from-my-awesome-bucket/uploads", "s3://my-awesome-bucket-staging")
        .and_return(['not important', nil, double(success?: true) ])

      trigger
    end
  end

end
