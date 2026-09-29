require 'tmpdir'

RSpec.describe Jstor::Downloader::Archive do
  let(:identifier)   { Jstor::Downloader::Identifier.new '4385670' }
  let(:client)       { Jstor::Downloader::Client.new(rate_limit: 0) }
  let(:expected_dir) { '1907/10/05/clasweek/4385670-the-elements-of-the-translation-of-latin' }

  let(:metadata_url) { 'https://archive.org/metadata/jstor-4385670' }
  let(:pdf_url)      { 'https://archive.org/download/jstor-4385670/4385670.pdf' }
  let(:text_url)     { 'https://archive.org/download/jstor-4385670/4385670_djvu.txt' }
  let(:xml_url)      { 'https://archive.org/download/jstor-4385670/10.2307_4385670.xml' }

  before do
    stub_request(:get, metadata_url).to_return(status: 200, body: File.read('spec/fixtures/http/metadata-4385670.json'))
    stub_request(:get, pdf_url).to_return(status: 200, body: File.binread('spec/fixtures/http/pdf-4385670.pdf'))
    stub_request(:get, text_url).to_return(status: 200, body: File.read('spec/fixtures/http/text-4385670.txt'))
    stub_request(:get, xml_url).to_return(status: 200, body: File.read('spec/fixtures/http/jstor-xml-4385670.xml'))
  end

  def run_in root
    described_class.new(identifier, root: root, client: client).run
  end

  describe '#run' do
    it 'returns the absolute path of the article folder' do
      Dir.mktmpdir do |root|
        expect(run_in(root)).to eq File.join(root, expected_dir)
      end
    end

    it 'writes the PDF, OCR text, JSTOR XML, and four sidecars' do
      Dir.mktmpdir do |root|
        dir = run_in root

        expect(File.binread(File.join(dir, '4385670.pdf'))).to eq File.binread('spec/fixtures/http/pdf-4385670.pdf')
        expect(File.read(File.join(dir, '4385670.txt'))).to    eq File.read('spec/fixtures/http/text-4385670.txt')
        expect(File.read(File.join(dir, 'jstor.xml'))).to      eq File.read('spec/fixtures/http/jstor-xml-4385670.xml')
        %w[metadata.md metadata.yaml metadata.json metadata.bib].each do |name|
          expect(File).to exist File.join(dir, name)
        end
      end
    end

    it 'never requests anything from jstor.org' do
      Dir.mktmpdir do |root|
        run_in root

        expect(WebMock).not_to have_requested(:any, /jstor\.org/)
      end
    end

    context 'when the item has no OCR text or JSTOR XML' do
      before do
        stub_request(:get, text_url).to_return(status: 404)
        stub_request(:get, xml_url).to_return(status: 404)
      end

      it 'archives the rest' do
        Dir.mktmpdir do |root|
          dir = run_in root

          expect(File).to     exist File.join(dir, '4385670.pdf')
          expect(File).not_to exist File.join(dir, '4385670.txt')
          expect(File).not_to exist File.join(dir, 'jstor.xml')
        end
      end
    end

    context 'when archive.org has no such item' do
      before { stub_request(:get, metadata_url).to_return(status: 200, body: '{}') }

      it 'raises ItemNotFound and writes nothing' do
        Dir.mktmpdir do |root|
          expect { run_in root }.to raise_error Jstor::Downloader::ItemNotFound
          expect(Dir.children(root)).to be_empty
        end
      end
    end

    context 'when the article is already archived' do
      it 'skips the downloads and returns the existing folder' do
        Dir.mktmpdir do |root|
          run_in root

          expect(run_in(root)).to eq File.join(root, expected_dir)
          expect(WebMock).to have_requested(:get, pdf_url).once
        end
      end
    end

    context 'when a download fails partway' do
      before { stub_request(:get, pdf_url).to_return(status: 500) }

      it 'leaves no article folder, so it is not mistaken for archived' do
        Dir.mktmpdir do |root|
          expect { run_in root }.to raise_error Jstor::Downloader::HTTPError
          expect(File).not_to exist File.join(root, expected_dir)
        end
      end
    end
  end
end
