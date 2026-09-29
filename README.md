# jstor-dl

Download articles from JSTOR's public-domain Early Journal Content for offline archives.

For each article, `jstor-dl` saves:

- The scanned PDF
- The OCR plaintext
- JSTOR's own article metadata (XML), verbatim
- Four sidecar metadata files: `metadata.md`, `metadata.yaml`, `metadata.json`, `metadata.bib`

## Where the content comes from

`jstor-dl` fetches only from the [Internet Archive's copy](https://archive.org/details/jstor_ejc) of JSTOR's Early Journal Content, never from jstor.org. [JSTOR's terms](https://about.jstor.org/terms) forbid any tool from downloading from jstor.org, even a single article; they allow only manual downloading.

The Early Journal Content is nearly 500,000 public-domain articles from 200+ journals (published before 1923 in the US, before 1870 elsewhere), released by JSTOR for free non-commercial use with acknowledgement, and uploaded to the Internet Archive in 2013 for bulk harvesting. Articles JSTOR added to its Early Journal Content after 2013 may be missing from the Internet Archive's copy.

## Installation

```sh
gem install jstor-dl
```

## CLI usage

```sh
jstor-dl <JSTOR_ID_OR_URL> [<JSTOR_ID_OR_URL>...]
```

Accepted input forms:

| Form                    | Example                                                  |
| ----------------------- | -------------------------------------------------------- |
| Stable ID               | `4385670`                                                |
| JSTOR URL               | `https://www.jstor.org/stable/4385670`                   |
| JSTOR URL, DOI form     | `https://www.jstor.org/stable/10.2307/4385670`           |
| JSTOR PDF URL           | `https://www.jstor.org/stable/pdf/4385670.pdf`           |
| DOI                     | `10.2307/4385670`, `doi:10.2307/4385670`                 |
| DOI URL                 | `https://doi.org/10.2307/4385670`                        |
| Internet Archive item   | `jstor-4385670`                                          |
| Internet Archive URL    | `https://archive.org/details/jstor-4385670`              |

JSTOR URLs are only read for the article's ID; nothing is requested from jstor.org.

### Flags

| Flag                      | Description                                                                   |
| ------------------------- | ----------------------------------------------------------------------------- |
| `-i FILE`, `--input FILE` | Read IDs/URLs from FILE, one per line (`-` for stdin; blanks and `#` skipped) |
| `-p PATH`, `--path PATH`  | Root download directory                                                       |
| `--rate-limit SECONDS`    | Seconds between HTTP requests; `0` disables throttling                        |
| `-v`, `--verbose`         | Print step lines and per-request URL/byte logs to stdout                      |
| `-q`, `--quiet`           | Print nothing to stdout; errors still go to stderr                            |
| `--version`               | Print the gem version and exit                                                |
| `-h`, `--help`            | Print help and exit                                                           |

`-v` and `-q` are mutually exclusive.

### Environment variables

| Variable              | Effect                                                            |
| --------------------- | ----------------------------------------------------------------- |
| `JSTOR_DOWNLOAD_PATH` | Root download directory (default: `$HOME/Downloads/JSTOR_Papers`) |
| `JSTOR_RATE_LIMIT`    | Seconds between HTTP requests (default: `3`; `0` disables)        |

Precedence: CLI flag > ENV var > default.

### Errors and exit status

A target that fails (unrecognized ID, not in the Early Journal Content on archive.org, HTTP error, network failure) is reported on stderr as `<target>: <message>`, and the remaining targets still download. Exit status is `0` when every target succeeds and `1` when any fails.

## Output layout

```txt
$JSTOR_DOWNLOAD_PATH/                   # default: $HOME/Downloads/JSTOR_Papers
  YYYY/MM/DD/<journal>/<jstor-id>-<slug>/
    <jstor-id>.pdf                      # scanned article
    <jstor-id>.txt                      # OCR plaintext
    jstor.xml                           # JSTOR's article metadata, verbatim
    metadata.md                         # YAML frontmatter + Markdown body
    metadata.yaml
    metadata.json
    metadata.bib                        # synthesized from the metadata
```

`YYYY/MM/DD` is the publication date (shorter when only the year or month is known). `<journal>` is JSTOR's journal abbreviation (`clasweek` for The Classical Weekly). `<slug>` is derived from the article title.

Each article downloads into a sibling `.partial` folder and is renamed into place only when every file succeeded. Re-running skips articles already archived.

## Library usage

```ruby
require 'jstor/downloader'

identifier = Jstor::Downloader::Identifier.new 'https://www.jstor.org/stable/4385670'
client     = Jstor::Downloader::Client.new                # 3-second rate limit by default
path       = Jstor::Downloader::Archive.new(identifier, root: '/tmp/papers', client: client).run
# => "/tmp/papers/1907/10/05/clasweek/4385670-the-elements-of-the-translation-of-latin"
```

## Development

```sh
script/setup    # install dependencies
script/test     # run specs and rubocop
script/console  # interactive prompt
```

Specs run offline against recorded fixtures in `spec/fixtures/http/`. To check those fixtures against the live archive.org API, run:

```sh
ARCHIVE_LIVE=1 script/test
```

## License

MIT — see [LICENSE.md](LICENSE.md).

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/version/3/0/) 3.0 — see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
