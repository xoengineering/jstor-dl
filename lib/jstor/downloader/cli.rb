module Jstor
  module Downloader
    class CLI < DL::Core::CLI
      def program = 'jstor-dl'

      def target_name = 'JSTOR_ID_OR_URL'

      # JSTOR_DOWNLOAD_PATH, JSTOR_RATE_LIMIT
      def env_prefix = 'JSTOR'

      def default_path = File.join(Dir.home, 'Downloads', 'JSTOR_Papers')

      def version = VERSION

      def user_agent = Client::USER_AGENT

      def client_for(rate_limit:, log:) = Client.new(rate_limit:, log:)

      def identifier_for(target) = Identifier.new(target)

      def archive_for(identifier, root:, client:) = Archive.new(identifier, root:, client:)
    end
  end
end
