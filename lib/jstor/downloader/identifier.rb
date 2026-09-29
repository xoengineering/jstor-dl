require 'uri'

module Jstor
  module Downloader
    # A JSTOR stable ID for an Early Journal Content article. EJC stable IDs are
    # numeric; JSTOR's newer IDs (j.ctt…, resrep…) are never in the EJC.
    class Identifier
      class Invalid < Error; end

      STABLE_ID = /\A\d+\z/
      DOI       = %r{\A(?:doi:)?10\.2307/(\d+)\z}i
      ITEM      = /\Ajstor-(\d+)\z/

      JSTOR_PATHS   = [%r{\A/stable/(?:10\.2307/)?(\d+)\z}, %r{\A/stable/pdf/(\d+)\.pdf\z}].freeze
      DOI_PATH      = %r{\A/10\.2307/(\d+)\z}
      ARCHIVE_PATH  = %r{\A/(?:details|download)/jstor-(\d+)(?:/|\z)}
      JSTOR_HOSTS   = %w[jstor.org www.jstor.org].freeze
      DOI_HOSTS     = %w[doi.org dx.doi.org].freeze
      ARCHIVE_HOSTS = %w[archive.org www.archive.org].freeze

      attr_reader :id, :input

      def initialize input
        @input = input
        @id    = parse input.to_s.strip
        raise Invalid, "not a JSTOR Early Journal Content identifier: #{input}" if @id.nil?
      end

      # the archive.org item holding this article
      def item = "jstor-#{id}"

      def doi = "10.2307/#{id}"

      def to_s = id

      private

      def parse text
        return text if STABLE_ID.match? text
        return Regexp.last_match(1) if DOI.match(text) || ITEM.match(text)

        parse_url text
      end

      def parse_url text
        uri  = URI.parse(text.include?('://') ? text : "https://#{text}")
        path = uri.path.to_s

        return first_capture(JSTOR_PATHS, path) if JSTOR_HOSTS.include? uri.host
        return first_capture([DOI_PATH], path)  if DOI_HOSTS.include? uri.host

        first_capture([ARCHIVE_PATH], path) if ARCHIVE_HOSTS.include? uri.host
      rescue URI::InvalidURIError
        nil
      end

      def first_capture patterns, path
        patterns.each do |pattern|
          match = pattern.match path
          return match[1] if match
        end
        nil
      end
    end
  end
end
