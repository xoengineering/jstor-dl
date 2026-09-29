require 'tmpdir'

RSpec.describe Jstor::Downloader::ItemFile do
  let(:identifier) { Jstor::Downloader::Identifier.new '4385670' }
  let(:client)     { Jstor::Downloader::Client.new(rate_limit: 0) }
  let(:fixture)    { File.binread 'spec/fixtures/http/pdf-4385670.pdf' }
  let(:url)        { 'https://archive.org/download/jstor-4385670/4385670.pdf' }

  before { stub_request(:get, url).to_return(status: 200, body: fixture) }

  describe '#download' do
    it 'writes the file from the archive.org item to the target path' do
      Dir.mktmpdir do |dir|
        target = File.join dir, '4385670.pdf'
        described_class.new(identifier, '4385670.pdf', client: client).download to: target

        expect(File.binread(target)).to eq fixture
      end
    end

    it 'requests the file from the item' do
      Dir.mktmpdir do |dir|
        described_class.new(identifier, '4385670.pdf', client: client).download to: File.join(dir, 'a.pdf')

        expect(WebMock).to have_requested(:get, url)
      end
    end
  end
end
