require_relative '../../lib/clean_config/ext/recursive_open_struct'

module CleanConfig
  describe RecursiveOpenStruct do
    context 'monkey patched methods' do
      let(:subject) do
        hash = { key1: 'value1', key2: 'value2' }
        RecursiveOpenStruct.new(hash, recurse_over_arrays: true)
      end

      it 'responds to keys' do
        expect(subject.keys).to include(:key1)
        expect(subject.keys).to include(:key2)
      end

      it 'responds to fetch' do
        expect(subject.fetch(:key1)).to eql('value1')
        expect(subject.fetch(:monkey, 'default')).to eql('default')
      end
    end
  end
end
