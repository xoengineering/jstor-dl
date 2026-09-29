require 'fileutils'

module Jstor
  module Downloader
    class Archive
      def initialize identifier, root:, client: Client.new
        @identifier = identifier
        @root       = root
        @client     = client
      end

      # Downloads into <article>.partial/ and
      # renames it into place only once everything succeeded.
      # An existing article folder is always complete and is skipped.
      def run
        return article_dir if Dir.exist? article_dir

        FileUtils.rm_rf staging_dir
        FileUtils.mkdir_p staging_dir

        download_pdf
        download_text
        download_jstor_xml
        write_sidecars

        File.rename staging_dir, article_dir
        article_dir
      end

      private

      def metadata
        @metadata ||= MetadataParser.new(@client.get(metadata_url).to_s).metadata
      end

      def metadata_url
        "https://archive.org/metadata/#{@identifier.item}"
      end

      def article_dir
        @article_dir ||= File.join @root, Path.new(metadata).to_s
      end

      # a sibling of article_dir, so the rename is a single atomic step
      def staging_dir
        "#{article_dir}.partial"
      end

      def download_pdf
        ItemFile.new(@identifier, "#{@identifier}.pdf", client: @client)
                .download to: File.join(staging_dir, "#{@identifier}.pdf")
      end

      # the OCR plaintext, when the item has it
      def download_text
        download_optional "#{@identifier}_djvu.txt", to: File.join(staging_dir, "#{@identifier}.txt")
      end

      # JSTOR's own article metadata, verbatim, when the item has it
      def download_jstor_xml
        download_optional "10.2307_#{@identifier}.xml", to: File.join(staging_dir, 'jstor.xml')
      end

      def download_optional name, to:
        ItemFile.new(@identifier, name, client: @client).download to: to
      rescue HTTPError => e
        raise unless e.status == 404
      end

      def write_sidecars
        Metadata::Markdown.new(metadata).write to: staging_dir
        Metadata::YAML.new(metadata).write     to: staging_dir
        Metadata::JSON.new(metadata).write     to: staging_dir
        Metadata::Bibtex.new(metadata).write   to: staging_dir
      end
    end
  end
end
