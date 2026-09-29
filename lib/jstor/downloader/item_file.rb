module Jstor
  module Downloader
    # One file from the article's archive.org item. /download/ redirects to a
    # storage node; Client follows redirects across hosts.
    class ItemFile
      def initialize identifier, name, client:
        @identifier = identifier
        @name       = name
        @client     = client
      end

      def download to:
        File.binwrite to, @client.get(url).to_s
      end

      private

      def url
        "https://archive.org/download/#{@identifier.item}/#{@name}"
      end
    end
  end
end
