require_relative 'downloader/client'
require_relative 'downloader/error'      # before errors below that subclass Error
require_relative 'downloader/http_error' # after error
require_relative 'downloader/identifier' # after error
require_relative 'downloader/version'

module Jstor
  module Downloader
  end
end
