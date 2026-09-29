module Jstor
  module Downloader
    class ItemNotFound < Error
      MESSAGE = <<~MESSAGE.chomp
        not in the Early Journal Content on archive.org (JSTOR's terms allow only manual download from jstor.org)
      MESSAGE

      def initialize message = MESSAGE
        super
      end
    end
  end
end
