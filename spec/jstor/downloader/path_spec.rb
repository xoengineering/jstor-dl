RSpec.describe Jstor::Downloader::Path do
  let(:metadata) { Jstor::Downloader::MetadataParser.new(File.read('spec/fixtures/http/metadata-4385670.json')).metadata }

  describe '#to_s' do
    it 'is YYYY/MM/DD/<journal>/<id>-<slug>' do
      expect(described_class.new(metadata).to_s)
        .to eq '1907/10/05/clasweek/4385670-the-elements-of-the-translation-of-latin'
    end

    it 'uses only the date parts that are known' do
      expect(described_class.new(metadata.with(published: '1907')).to_s)
        .to eq '1907/clasweek/4385670-the-elements-of-the-translation-of-latin'
    end
  end
end
