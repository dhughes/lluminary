require 'spec_helper'

RSpec.describe Lluminary::Config do
  let(:config) { described_class.new }

  describe '#configure' do
    it 'allows setting provider configurations' do
      config.configure do |c|
        c.provider(:openai, api_key: 'global-key')
        c.provider(:bedrock, 
          access_key_id: 'global-access-key',
          secret_access_key: 'global-secret-key',
          region: 'us-east-1'
        )
      end

      expect(config.provider_config(:openai)).to eq({ api_key: 'global-key' })
      expect(config.provider_config(:bedrock)).to eq({
        access_key_id: 'global-access-key',
        secret_access_key: 'global-secret-key',
        region: 'us-east-1'
      })
    end
  end

  describe '#provider_config' do
    it 'returns empty hash for unconfigured providers' do
      expect(config.provider_config(:unknown)).to eq({})
    end

    it 'returns the configuration for a configured provider' do
      config.configure do |c|
        c.provider(:openai, api_key: 'test-key')
      end

      expect(config.provider_config(:openai)).to eq({ api_key: 'test-key' })
    end
  end

  describe '#reset!' do
    it 'clears all provider configurations' do
      config.configure do |c|
        c.provider(:openai, api_key: 'test-key')
        c.provider(:bedrock, access_key_id: 'test-access-key')
      end

      config.reset!

      expect(config.provider_config(:openai)).to eq({})
      expect(config.provider_config(:bedrock)).to eq({})
    end
  end
end 