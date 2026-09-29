require 'tmpdir'
require 'yaml'

RSpec.describe Jstor::Downloader::Metadata::Markdown do
  let(:metadata) { Jstor::Downloader::MetadataParser.new(File.read('spec/fixtures/http/metadata-4385670.json')).metadata }

  def written metadata
    Dir.mktmpdir do |dir|
      described_class.new(metadata).write to: dir
      File.read File.join(dir, 'metadata.md')
    end
  end

  describe '#write' do
    it 'opens with YAML frontmatter holding every field plus the BibTeX key' do
      _, frontmatter_text, = written(metadata).split(/^---\n/, 3)
      frontmatter = YAML.safe_load frontmatter_text

      expect(frontmatter.keys).to include('jstor_id', 'doi', 'title', 'authors', 'published', 'journal', 'bibtex_key')
      expect(frontmatter['bibtex_key']).to eq 'greene1907the'
    end

    it 'has a body with the title, authors, citation, links, and the JSTOR acknowledgement' do
      body = written(metadata).split(/^---\n/, 3).last

      expect(body).to include '# The Elements of the Translation of Latin'
      expect(body).to include '- Ella Catherine Greene'
      expect(body).to include '- Published: 1907-10-05'
      expect(body).to include '- The Classical Weekly, volume 1, pages 2-5'
      expect(body).to include '- JSTOR: [10.2307/4385670](https://www.jstor.org/stable/4385670)'
      expect(body).to include '- Internet Archive: [jstor-4385670](https://archive.org/details/jstor-4385670)'
      expect(body).to include 'JSTOR Early Journal Content'
    end
  end
end
