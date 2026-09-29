require 'tmpdir'

RSpec.describe Jstor::Downloader::Metadata::Bibtex do
  let(:metadata) { Jstor::Downloader::MetadataParser.new(File.read('spec/fixtures/http/metadata-4385670.json')).metadata }

  describe '#write' do
    it 'writes the synthesized entry to metadata.bib' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        expect(File.read(File.join(dir, 'metadata.bib'))).to eq Jstor::Downloader::Bibtex.new(metadata).to_s
      end
    end
  end
end
