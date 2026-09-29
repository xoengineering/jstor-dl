## [Unreleased]

- Built on [dl-core](https://github.com/xoengineering/dl-core) 0.1: the HTTP client, errors, `Author`, `Slug`, sidecar writers, and CLI now come from it instead of copies. No change in behavior or output. `Jstor::Downloader::Client`, `HTTPError`, `Author`, `Slug`, and `Metadata::YAML`/`JSON` still work; they are now `dl-core`'s classes. `Jstor::Downloader::Error` now subclasses `DL::Core::Error`.

## [0.1.0]

First version. Per-article offline archive of JSTOR's public-domain Early Journal Content, fetched only from the Internet Archive's copy, never from jstor.org.

- Accepts JSTOR stable IDs, jstor.org URLs, `10.2307/…` DOIs and doi.org URLs, and archive.org `jstor-…` items and URLs.
- Saves the scanned PDF, the OCR plaintext, JSTOR's article metadata XML verbatim, and four sidecar metadata files (`metadata.md`, `metadata.yaml`, `metadata.json`, `metadata.bib`).
- Layout: `YYYY/MM/DD/<journal>/<jstor-id>-<slug>/`.
- Articles not in the Early Journal Content on archive.org raise `Jstor::Downloader::ItemNotFound`.
- Rate-limited HTTP client (3s default) with timeouts and retries on 429/503, staged downloads that skip already-archived articles, and a CLI with `--input FILE|-`, per-target error reporting, and exit status 1 on any failure. All copied from arxiv-dl.
