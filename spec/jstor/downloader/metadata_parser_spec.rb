RSpec.describe Jstor::Downloader::MetadataParser do
  let(:json)     { File.read 'spec/fixtures/http/metadata-4385670.json' }
  let(:metadata) { described_class.new(json).metadata }

  describe '#metadata' do
    it 'extracts the JSTOR stable ID and derives the DOI and URLs' do
      expect(metadata.jstor_id).to    eq '4385670'
      expect(metadata.doi).to         eq '10.2307/4385670'
      expect(metadata.jstor_url).to   eq 'https://www.jstor.org/stable/4385670'
      expect(metadata.archive_url).to eq 'https://archive.org/details/jstor-4385670'
    end

    it 'extracts the title' do
      expect(metadata.title).to eq 'The Elements of the Translation of Latin'
    end

    it 'extracts the authors as Author objects, names as given' do
      expect(metadata.authors).to eq [Jstor::Downloader::Author.new(name: 'Ella Catherine Greene')]
    end

    it 'keeps the published date as given' do
      expect(metadata.published).to eq '1907-10-05'
    end

    it 'extracts the journal as id and name' do
      expect(metadata.journal).to eq(id: 'clasweek', name: 'The Classical Weekly')
    end

    it 'extracts the bibliographic details' do
      expect(metadata.volume).to       eq '1'
      expect(metadata.pages).to        eq '2-5'
      expect(metadata.issn).to         eq '1940641X'
      expect(metadata.language).to     eq 'eng'
      expect(metadata.publisher).to    eq 'The Classical Weekly'
      expect(metadata.article_type).to eq 'research-article'
    end
  end

  context 'when creator is a list' do
    let(:json) do
      parsed = JSON.parse File.read('spec/fixtures/http/metadata-4385670.json')
      parsed['metadata']['creator'] = ['Stebbins, Joel', 'Wheeler, W. C.']
      JSON.generate parsed
    end

    it 'keeps every author in order' do
      expect(metadata.authors.map(&:name)).to eq ['Stebbins, Joel', 'Wheeler, W. C.']
    end
  end

  context 'when the item has no creator' do
    let(:json) do
      parsed = JSON.parse File.read('spec/fixtures/http/metadata-4385670.json')
      parsed['metadata'].delete 'creator'
      JSON.generate parsed
    end

    it 'has no authors' do
      expect(metadata.authors).to eq []
    end
  end

  context 'when archive.org has no such item' do
    let(:json) { File.read 'spec/fixtures/http/metadata-missing.json' }

    it 'raises ItemNotFound' do
      expect { metadata }.to raise_error Jstor::Downloader::ItemNotFound
    end
  end
end
