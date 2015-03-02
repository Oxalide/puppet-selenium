require 'spec_helper'

describe 'selenium::chrome', :type => :class do
    let(:params) { {:version => '2.0.0', :target_directory => '/tmp' } }

    it { should contain_puppi__project__archive('chrome_driver') \
        .with_source('http://chromedriver.storage.googleapis.com/2.0.0/chromedriver_linux32.zip') \
        .with_deploy_root('/tmp') \
        .with_auto_deploy(true) \
        .with_enable(true)
    }

    it { should contain_file('chrome_driver_link') \
      .with_ensure('/tmp') \
      .with_path('/tmp/chromedriver')
    }
end
