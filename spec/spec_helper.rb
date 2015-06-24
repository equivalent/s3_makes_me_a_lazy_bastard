$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 's3_makes_me_a_lazy_bastard'

def should_create_folder(folder_path)
  expect(executor)
    .to receive(:call)
    .with("mkdir", "-p", folder_path)
    .and_return(['not important', nil, double(success?: true) ])

  expect(executor)
    .to receive(:call)
    .with("rm", "-rf", folder_path)
    .and_return(['not important', nil, double(success?: true) ])

  expect(executor)
    .to receive(:call)
    .with("mkdir", "-p", folder_path)
    .and_return(['not important', nil, double(success?: true) ])
end
