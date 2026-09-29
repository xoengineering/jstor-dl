require 'fileutils'

module Jstor
  module Downloader
    class Metadata
      class Bibtex
        FILENAME = 'metadata.bib'.freeze

        def initialize metadata
          @metadata = metadata
        end

        def write to:
          FileUtils.mkdir_p to
          File.write File.join(to, FILENAME), Downloader::Bibtex.new(@metadata).to_s
        end
      end
    end
  end
end
