require 'tmpdir'

RSpec.describe Jstor::Downloader::CLI do
  let(:stdout)       { StringIO.new }
  let(:stderr)       { StringIO.new }
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

  def run_with arguments, stdin: StringIO.new
    described_class.new(arguments, stderr: stderr, stdin: stdin, stdout: stdout).run
  end

  def with_env vars
    previous = vars.to_h { |key, _| [key.to_s, ENV.fetch(key.to_s, nil)] }
    vars.each { |key, value| ENV[key.to_s] = value }
    yield
  ensure
    previous.each { |key, value| ENV[key] = value }
  end

  describe '#run' do
    context 'with a target and -p path' do
      it 'returns 0 and prints the article folder' do
        Dir.mktmpdir do |root|
          expect(run_with(['-p', root, '--rate-limit', '0', '4385670'])).to eq 0
          expect(stdout.string).to eq "#{File.join(root, expected_dir)}\n"
          expect(File).to exist File.join(root, expected_dir, '4385670.pdf')
        end
      end
    end

    context 'with -q (quiet)' do
      it 'prints nothing on success' do
        Dir.mktmpdir do |root|
          run_with ['-p', root, '--rate-limit', '0', '-q', '4385670']

          expect(stdout.string).to be_empty
        end
      end
    end

    context 'with -v (verbose)' do
      it 'prints step lines and request logs to stdout' do
        Dir.mktmpdir do |root|
          run_with ['-p', root, '--rate-limit', '0', '-v', '4385670']

          expect(stdout.string).to include '==> Downloading 4385670'
          expect(stdout.string).to include "==> GET #{pdf_url}"
        end
      end
    end

    context 'with -v and -q together' do
      it 'exits non-zero with an error on stderr' do
        expect(run_with(['-v', '-q', '4385670'])).to eq 1
        expect(stderr.string).to include 'mutually exclusive'
      end
    end

    context 'with --version' do
      it 'prints the version and exits 0' do
        expect(run_with(['--version'])).to eq 0
        expect(stdout.string).to eq "#{Jstor::Downloader::VERSION}\n"
      end
    end

    context 'with -h' do
      it 'prints help and exits 0' do
        expect(run_with(['-h'])).to eq 0
        expect(stdout.string).to include 'Usage: jstor-dl'
      end
    end

    context 'with no targets' do
      it 'prints usage to stderr and exits non-zero' do
        expect(run_with([])).to eq 1
        expect(stderr.string).to include 'Usage'
      end
    end

    context 'with --input FILE' do
      it 'downloads each ID listed in the file, skipping blanks and # comments' do
        Dir.mktmpdir do |root|
          expect(run_with(['-p', root, '--rate-limit', '0', '--input', 'spec/fixtures/targets.txt'])).to eq 0
          expect(stdout.string).to eq "#{File.join(root, expected_dir)}\n"
        end
      end
    end

    context 'with --input -' do
      it 'reads IDs from stdin' do
        Dir.mktmpdir do |root|
          run_with ['-p', root, '--rate-limit', '0', '--input', '-'], stdin: StringIO.new("10.2307/4385670\n")

          expect(stdout.string).to eq "#{File.join(root, expected_dir)}\n"
        end
      end
    end

    context 'when some targets fail' do
      before do
        stub_request(:get, 'https://archive.org/metadata/jstor-1234').to_return(status: 200, body: '{}')
      end

      it 'reports each failure on stderr, keeps going, and exits non-zero' do
        Dir.mktmpdir do |root|
          status = run_with ['-p', root, '--rate-limit', '0', 'not-an-id', '1234', '4385670']

          expect(status).to eq 1
          expect(stdout.string).to eq "#{File.join(root, expected_dir)}\n"
          expect(stderr.string.lines).to eq [
            "not-an-id: not a JSTOR Early Journal Content identifier: not-an-id\n",
            "1234: #{Jstor::Downloader::ItemNotFound.new.message}\n"
          ]
        end
      end
    end

    context 'with ENV JSTOR_DOWNLOAD_PATH' do
      it 'uses ENV when -p is not provided, and -p wins over ENV' do
        Dir.mktmpdir do |env_root|
          Dir.mktmpdir do |flag_root|
            with_env JSTOR_DOWNLOAD_PATH: env_root, JSTOR_RATE_LIMIT: '0' do
              run_with ['4385670']
              run_with ['-p', flag_root, '4385670']
            end

            expect(File).to exist File.join(env_root, expected_dir, '4385670.pdf')
            expect(File).to exist File.join(flag_root, expected_dir, '4385670.pdf')
          end
        end
      end
    end
  end
end
