require 'json'
require 'tmpdir'

RSpec.describe Jstor::Downloader::Metadata::JSON do
  let(:metadata) { Jstor::Downloader::MetadataParser.new(File.read('spec/fixtures/http/metadata-4385670.json')).metadata }

  describe '#write' do
    it 'writes pretty-printed metadata.json with string keys, authors and journal as nested objects' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        text   = File.read File.join(dir, 'metadata.json')
        loaded = JSON.parse text
        expect(text).to include %(\n  "jstor_id": "4385670")
        expect(loaded.fetch('authors')).to eq [{ 'name' => 'Ella Catherine Greene', 'affiliations' => [] }]
        expect(loaded.fetch('journal')).to eq('id' => 'clasweek', 'name' => 'The Classical Weekly')
      end
    end
  end
end
