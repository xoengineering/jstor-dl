require 'fileutils'
require 'yaml'

module Jstor
  module Downloader
    class Metadata
      class Markdown
        FILENAME = 'metadata.md'.freeze

        def initialize metadata
          @metadata = metadata
        end

        def write to:
          FileUtils.mkdir_p to
          File.write File.join(to, FILENAME), "#{frontmatter}\n#{body}"
        end

        private

        def frontmatter
          "---\n#{::YAML.dump(stringify(frontmatter_hash)).delete_prefix("---\n")}---"
        end

        def frontmatter_hash
          @metadata.to_h.merge bibtex_key: bibtex_key
        end

        def bibtex_key
          Downloader::Bibtex.new(@metadata).key
        end

        def stringify object
          case object
          when Hash  then object.to_h { |key, value| [key.to_s, stringify(value)] }
          when Array then object.map { |item| stringify item }
          when Data  then stringify object.to_h
          else object
          end
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
