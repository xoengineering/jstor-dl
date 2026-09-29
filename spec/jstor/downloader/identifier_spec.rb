RSpec.describe Jstor::Downloader::Identifier do
  describe '.new' do
    {
      '4385670'                                                => 'bare stable ID',
      ' 4385670 '                                              => 'bare stable ID with whitespace',
      'https://www.jstor.org/stable/4385670'                   => 'JSTOR stable URL',
      'http://jstor.org/stable/4385670'                        => 'JSTOR stable URL, http, no www',
      'www.jstor.org/stable/4385670'                           => 'JSTOR stable URL without scheme',
      'https://www.jstor.org/stable/4385670?seq=1'             => 'JSTOR stable URL with query',
      'https://www.jstor.org/stable/10.2307/4385670'           => 'JSTOR stable URL with DOI prefix',
      'https://www.jstor.org/stable/pdf/4385670.pdf'           => 'JSTOR PDF URL',
      '10.2307/4385670'                                        => 'DOI',
      'doi:10.2307/4385670'                                    => 'DOI with doi: prefix',
      'https://doi.org/10.2307/4385670'                        => 'DOI URL',
      'jstor-4385670'                                          => 'archive.org item identifier',
      'https://archive.org/details/jstor-4385670'              => 'archive.org details URL',
      'https://archive.org/download/jstor-4385670/4385670.pdf' => 'archive.org download URL'
    }.each do |input, form|
      it "parses a #{form}" do
        expect(described_class.new(input).id).to eq '4385670'
      end
    end

    [
      nil,
      '',
      'not an id',
      '10.2307/j.ctt1234',
      'https://www.jstor.org/stable/j.ctt1234',
      'https://example.com/stable/4385670',
      '10.1000/4385670'
    ].each do |input|
      it "rejects #{input.inspect}" do
        expect { described_class.new input }.to raise_error described_class::Invalid
      end
    end

    it 'names the input in the error message' do
      expect { described_class.new 'not an id' }
        .to raise_error described_class::Invalid, 'not a JSTOR Early Journal Content identifier: not an id'
    end
  end

  describe '#item' do
    it 'is the archive.org item identifier' do
      expect(described_class.new('4385670').item).to eq 'jstor-4385670'
    end
  end

  describe '#doi' do
    it "is JSTOR's DOI for the article" do
      expect(described_class.new('4385670').doi).to eq '10.2307/4385670'
    end
  end

  describe '#to_s' do
    it 'is the stable ID' do
      expect(described_class.new('jstor-4385670').to_s).to eq '4385670'
    end
  end
end
