require_relative '../../lib/clean_config/configurable'
require_relative '../../lib/clean_config/configuration'

module CleanConfig
  describe Configurable do
    context 'hooks' do
      it 'does not fail on include when config/config.yml not found' do
        expect do
          class ConfigTest
            include Configurable
          end
        end.not_to raise_error
      end
    end
  end
end
