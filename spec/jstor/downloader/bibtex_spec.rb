RSpec.describe Jstor::Downloader::Bibtex do
  let(:metadata) { Jstor::Downloader::MetadataParser.new(File.read('spec/fixtures/http/metadata-4385670.json')).metadata }

  describe '#to_s' do
    it 'synthesizes an @article entry from the metadata' do
      expect(described_class.new(metadata).to_s).to eq <<~BIBTEX
        @article{greene1907the,
          title={The Elements of the Translation of Latin},
          author={Ella Catherine Greene},
          journal={The Classical Weekly},
          year={1907},
          volume={1},
          pages={2--5},
          doi={10.2307/4385670},
          url={https://www.jstor.org/stable/4385670},
        }
      BIBTEX
    end

    it 'joins several authors with and' do
      authors = [
        Jstor::Downloader::Author.new(name: 'Stebbins, Joel'),
        Jstor::Downloader::Author.new(name: 'Wheeler, W. C.')
      ]

      expect(described_class.new(metadata.with(authors: authors)).to_s)
        .to include 'author={Stebbins, Joel and Wheeler, W. C.},'
    end
  end

  describe '#key' do
    it 'uses the surname before the comma for "Last, First" names' do
      authors = [Jstor::Downloader::Author.new(name: 'Stebbins, Joel')]

      expect(described_class.new(metadata.with(authors: authors)).key).to eq 'stebbins1907the'
    end

    it 'uses anonymous when there are no authors' do
      expect(described_class.new(metadata.with(authors: [])).key).to eq 'anonymous1907the'
    end
  end
end
