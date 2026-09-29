# Rate limiting, retries, and timeouts are specified in dl-core.
RSpec.describe Jstor::Downloader::Client do
  it 'is a DL::Core::Client' do
    expect(described_class.new).to be_a DL::Core::Client
  end

  it 'identifies jstor-dl with version and source URL' do
    expect(described_class.new.user_agent)
      .to eq "jstor-dl/#{Jstor::Downloader::VERSION} (+https://github.com/xoengineering/jstor-dl)"
  end

  it 'defaults to a 3-second rate limit' do
    expect(described_class.new.rate_limit).to eq 3
  end

  it 'passes the rate limit and log through' do
    log = StringIO.new
    url = 'https://archive.org/metadata/jstor-4385670'
    stub_request(:get, url).to_return(status: 200, body: '{}')

    client = described_class.new(rate_limit: 0, log: log)
    client.get url

    expect(client.rate_limit).to eq 0
    expect(log.string).to include "==> GET #{url}"
  end
end
