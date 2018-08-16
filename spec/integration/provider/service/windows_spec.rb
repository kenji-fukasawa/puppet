#! /usr/bin/env ruby
require 'spec_helper'

test_title = 'Integration Tests for Puppet::Type::Service::Provider::Windows'

describe test_title, '(integration)', :if => Puppet::Util::Platform.windows? do
  let(:provider_class) { Puppet::Type.type(:service).provider(:windows) }

  require 'puppet/util/windows'

  before :each do
    Puppet::Type.type(:service).stubs(:defaultprovider).returns provider_class
  end

  context 'should fail querying services that do not exist' do
    let(:service) do
      Puppet::Type.type(:service).new(:name => 'foobarservice1234')
    end

    it "with a Puppet::Error when querying enabled?" do
      expect { service.provider.enabled? }.to raise_error(Puppet::Error)
    end

    it "with a Puppet::Error when querying status" do
      expect { service.provider.status }.to raise_error(Puppet::Error)
    end
  end

  context 'should return valid values when querying a service that does exist' do
    let(:service) do
      # This service should be ubiquitous across all supported Windows platforms
      Puppet::Type.type(:service).new(:name => 'lmhosts')
    end

    it "with a valid enabled? value when asked if enabled" do
      expect([:true, :false, :manual]).to include(service.provider.enabled?)
    end

    it "with a valid status when asked about status" do
      expect([
        :running,
        :'continue pending',
        :'pause pending',
        :paused,
        :running,
        :'start pending',
        :'stop pending',
        :stopped]).to include(service.provider.status)
    end
  end
end
