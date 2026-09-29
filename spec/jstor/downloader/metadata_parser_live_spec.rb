# Opt-in drift check against the real archive.org API: `ARCHIVE_LIVE=1 script/test`.
# Fetches each item that has a recorded metadata fixture and expects it to parse
# into the same Metadata as the fixture. A failure means archive.org's metadata
# changed and the fixture needs re-recording.
RSpec.describe Jstor::Downloader::MetadataParser, :live do
  around do |example|
    WebMock.allow_net_connect!
    example.run
  ensure
    WebMock.disable_net_connect! allow_localhost: true
  end

  let(:client) { Jstor::Downloader::Client.new }

  it 'parses the live archive.org metadata the same as each recorded fixture' do
    aggregate_failures do
      Dir.glob('spec/fixtures/http/metadata-[0-9]*.json').each do |path|
        jstor_id = File.basename(path, '.json').delete_prefix('metadata-')
        response = client.get "https://archive.org/metadata/jstor-#{jstor_id}"

        live     = described_class.new(response.to_s).metadata
        recorded = described_class.new(File.read(path)).metadata

        expect(live).to eq(recorded), "#{jstor_id} drifted from #{path}"
      end
    end
  end
end
