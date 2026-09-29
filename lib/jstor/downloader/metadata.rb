module Jstor
  module Downloader
    # Field order is the reading order of the metadata sidecars.
    Metadata = Data.define(
      :jstor_id,
      :doi,
      :jstor_url,
      :archive_url,
      :title,
      :authors,
      :published,
      :journal,
      :volume,
      :pages,
      :issn,
      :language,
      :publisher,
      :article_type
    )
  end
end
