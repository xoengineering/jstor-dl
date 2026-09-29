module Jstor
  module Downloader
    class ItemNotFound < Error
      def initialize message = 'not in the Early Journal Content on archive.org'
        super
      end
    end
  end
end
