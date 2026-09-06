# Changelog

## [Unreleased]

### Fixed

- Writing to standard output (`-o -`) no longer corrupts the picture data on
  Windows. Windows opens standard output in text mode, so every line-feed byte
  in the frames was written as carriage-return plus line-feed: a five-frame
  clip came out as 30728 bytes where every other platform wrote 30720, and
  Y4M as 30804 against 30790. Writing to a named file was never affected.
  Checked on Windows 10 — the output is now byte-identical to Linux. The
  checksum muxers (`md5`, `xxh3`) still write text, which is what they are.

### Changed

- The Windows binary is now built by the same compiler as the Linux and macOS
  ones (2.10 MB to 2.02 MB). Checked on Windows 10: `--version`, and `--help`
  still lists every demuxer and muxer.

  It now uses the Universal C Runtime, which is part of Windows 10 and later.
  On Windows 7 or 8.1 that runtime has to be installed first — it comes through
  Windows Update. The previous binary did not need it.
