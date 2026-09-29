require 'tmpdir'
require 'yaml'

RSpec.describe Jstor::Downloader::Metadata::YAML do
  let(:metadata) { Jstor::Downloader::MetadataParser.new(File.read('spec/fixtures/http/metadata-4385670.json')).metadata }

  describe '#write' do
    it 'writes metadata.yaml with string keys, authors and journal as nested hashes' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        loaded = YAML.safe_load_file File.join(dir, 'metadata.yaml')
        expect(loaded.fetch('jstor_id')).to  eq '4385670'
        expect(loaded.fetch('doi')).to       eq '10.2307/4385670'
        expect(loaded.fetch('published')).to eq '1907-10-05'
        expect(loaded.fetch('authors')).to   eq [{ 'name' => 'Ella Catherine Greene', 'affiliations' => [] }]
        expect(loaded.fetch('journal')).to   eq('id' => 'clasweek', 'name' => 'The Classical Weekly')
      end
    end
  end
end
