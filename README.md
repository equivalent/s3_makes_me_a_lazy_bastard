# S3MakesMeALazyBastard

THIS GEM IS STILL IN PROGRESS AND NOT RELEASED YET


(at this point) This gem is Ruby wrapper around [s3cmd](http://s3tools.org/s3cmd) that
is:

* creating compressed backups of assest stored in production s3 bucket (A) to
  asset-backup s3 bucket (B)
* providing to fetch asset-backup from asset-backup (B) and command for
  uncompressing it and then upload it to  another
  (testing/stanging) server s3 bucket (C)

* (FEATURE IN PROGRESS) if use db backup s3-storege tools like `backup` gem that stores
  DB backups straight to dbbackup s3 bucket (D) you can use another task
  that will fetch and load this backup to your testing/staging server 


...and if you wrap this with simple rake tasks / cap tasks / jenkins
task, you will eventually create "one click" (command) interface that
would load db & asset state of your production server to your testing/staging
server, making you really lazy b4st4rd !

B.T.W. at this early stage I'm running `rm -rf yourbackupdir/` so be
carefull.

### Quick FAQs (and TODOs)

*why you're not uisng AWS ruby gem ?*

Because I had like a day to write this and had s3cmd in place. I'll
refactor it when I have time

* why `s3cmd` you not using [AWS CLI](http://aws.amazon.com/cli/) ?

true that `s3cmd` is depricated and `aws s3` should be used but because
I had s3cmd already on backup machine and I'll refactore it to AWS ruby
gem I didn't bother

* why the `rm -rf` for deleting old backups

was lazy, I'll refactore it

## Installation

Add this line to your application's Gemfile:

```ruby
gem 's3_makes_me_a_lazy_bastard', github: 'equivalent/s3_makes_me_a_lazy_bastard'
```

And then execute:

    $ bundle

## Usage

something like: 

```ruby
# Rakefile.rb
require 's3_makes_me_a_lazy_bastard'
namespace :s3 do
  namespace :production do
    def s3_logger
      @logger ||= Logger
        .new(STDOUT)
        .tap { |l| l.level = Logger::DEBUG }
    end

    desc 'create production assset backup and push it to backup bucket'
    task :create_assets_backup do
      options = {
        destination_bucket_name: 'myapp-test',
        source_bucket_name: 'myapp-production',
        transient_local_folder: Pathname.new("/tmp/s3_mmalb/myapp_backup"),
        backup_name: 'myapp-production-assets-backup',
        logger: s3_logger
      }
      S3MakesMeALazyBastard::CreateAssetsBackup.new(options).call
    end

    desc 'pull latest production assets backup'
    task :fetch_assets_backup do
      options = {
        source_bucket_name: 'myapp-production-s3backup',
        destination_local_folder: Pathname.new("/tmp/s3_mmalb/myapp_fetch"),
        logger: s3_logger
      }
      S3MakesMeALazyBastard::FetchAssetsBackup.new(options).call
    end
  end

  namespace :testing do
    desc 'push production assets backup to testing'
    task :push_assets do
      options = {
        destination_bucket_name: 'myapp-testing',
        source_local_folder: Pathname.new('/tmp/s3_mmalb/myapp-production/uploads'),
        logger: s3_logger
      }
      S3MakesMeALazyBastard::PushAssets.new(options).call
    end
  end

  namespace :staging do
    desc 'push production assets backup to staging'
    task :push_assets do
      options = {
        destination_bucket_name: 'myapp-staging',
        source_local_folder: Pathname.new('/tmp/s3_mmalb/myapp-production/uploads'),
        logger: s3_logger
      }
      S3MakesMeALazyBastard::PushAssets.new(options).call
    end
  end
end
```

## Contributing

1. Fork it ( https://github.com/equivalent/s3_makes_me_a_lazy_bastard/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
