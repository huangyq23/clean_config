require_relative '../../lib/core/core_one'

module Core
  describe CoreOne do
    context 'layers config' do
      it 'reads configs' do
        core_one = CoreOne.new
        expect(core_one.config.data.core).to eq('core value')
      end
    end
  end
end
