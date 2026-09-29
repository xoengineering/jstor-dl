require_relative 'downloader/author'
require_relative 'downloader/client'
require_relative 'downloader/error'           # before errors below that subclass Error
require_relative 'downloader/http_error'      # after error
require_relative 'downloader/identifier'      # after error
require_relative 'downloader/item_file'
require_relative 'downloader/item_not_found'  # after error
require_relative 'downloader/metadata'
require_relative 'downloader/metadata_parser'
require_relative 'downloader/path'
require_relative 'downloader/slug'
require_relative 'downloader/version'

module Jstor
  module Downloader
  end
end
