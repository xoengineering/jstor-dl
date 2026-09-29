module Jstor
  module Downloader
    class Path
      def initialize metadata
        @metadata = metadata
      end

      def to_s
        [date_dir, journal, "#{@metadata.jstor_id}-#{slug}"].join '/'
      end

      private

      # 1907-10-05 becomes 1907/10/05; a year-only or year-month date gives a shorter path
      def date_dir
        @metadata.published.to_s.split('-').join '/'
      end

      def journal
        @metadata.journal[:id]
      end

      def slug
        Slug.new(@metadata.title).to_s
      end
    end
  end
end
