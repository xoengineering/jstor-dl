require 'json'

module Jstor
  module Downloader
    # Parses an archive.org item metadata response (https://archive.org/metadata/jstor-<id>)
    class MetadataParser
      def initialize json
        @json = JSON.parse json
      end

      def metadata
        fields = @json['metadata']
        raise ItemNotFound if fields.nil?

        identifier = Identifier.new fields.fetch('identifier')

        Metadata.new(
          jstor_id:     identifier.id,
          doi:          identifier.doi,
          jstor_url:    "https://www.jstor.org/stable/#{identifier}",
          archive_url:  "https://archive.org/details/#{identifier.item}",
          title:        fields['title'],
          authors:      authors_from(fields['creator']),
          published:    fields['date'],
          journal:      { id: fields['journalabbrv'], name: fields['journaltitle'] },
          volume:       fields['volume'],
          pages:        fields['pagerange'],
          issn:         fields['issn'],
          language:     fields['language'],
          publisher:    fields['publisher'],
          article_type: fields['article-type']
        )
      end

      private

      # archive.org gives a string for one creator and a list for several
      def authors_from creator
        Array(creator).map { Author.new name: it }
      end
    end
  end
end
