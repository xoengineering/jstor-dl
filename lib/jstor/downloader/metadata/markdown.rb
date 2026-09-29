module Jstor
  module Downloader
    class Metadata
      # metadata.md: dl-core writes the frontmatter; the body is JSTOR-specific
      class Markdown
        def initialize metadata
          @metadata = metadata
        end

        def write to:
          DL::Core::Sidecar::Markdown.new(@metadata, body:, extras: { bibtex_key: }).write to:
        end

        private

        def bibtex_key
          Downloader::Bibtex.new(@metadata).key
        end

        # JSTOR asks for acknowledgement as the source of Early Journal Content
        def body
          <<~MARKDOWN

            # #{@metadata.title}

            #{authors_list}

            - Published: #{@metadata.published}
            - #{citation}
            - JSTOR: [#{@metadata.doi}](#{@metadata.jstor_url})
            - Internet Archive: [jstor-#{@metadata.jstor_id}](#{@metadata.archive_url})

            From JSTOR Early Journal Content, via the Internet Archive.
          MARKDOWN
        end

        def authors_list
          @metadata.authors.map { |author| "- #{author.name}" }.join "\n"
        end

        def citation
          "#{@metadata.journal[:name]}, volume #{@metadata.volume}, pages #{@metadata.pages}"
        end
      end
    end
  end
end
