module Jstor
  module Downloader
    # Synthesized from the metadata only: fetching JSTOR's own citation
    # export would be an automated download from jstor.org.
    class Bibtex
      def initialize metadata
        @metadata = metadata
      end

      def to_s
        <<~BIBTEX
          @article{#{key},
            title={#{@metadata.title}},
            author={#{authors}},
            journal={#{@metadata.journal[:name]}},
            year={#{year}},
            volume={#{@metadata.volume}},
            pages={#{pages}},
            doi={#{@metadata.doi}},
            url={#{@metadata.jstor_url}},
          }
        BIBTEX
      end

      def key
        title_word = Slug.new(@metadata.title).to_s.split('-').first

        "#{surname}#{year}#{title_word}"
      end

      private

      def authors
        @metadata.authors.map(&:name).join ' and '
      end

      # "Stebbins, Joel" and "Ella Catherine Greene" both give a lowercase surname
      def surname
        first_author = @metadata.authors.first
        return 'anonymous' if first_author.nil?

        name = first_author.name
        last = name.include?(',') ? name.split(',').first : name.split.last
        last.downcase.gsub(/[^a-z]/, '')
      end

      def year
        @metadata.published.to_s[0, 4]
      end

      # BibTeX page ranges use an en dash: 2--5
      def pages
        @metadata.pages.to_s.sub '-', '--'
      end
    end
  end
end
