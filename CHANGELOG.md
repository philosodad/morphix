# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [v0.0.4]
### Added
- added `:safe` option for `atomorphif*` functions, if used, only existing atoms will be used in string conversion.

### Changed
- `atomorphif*` functions do not use `String.to_existing_atom` unless `:safe` option is passed.

## [v0.0.3]
### Added
- `morphify!` and `morphify` functions
- `morphiflat!`
- use `String.to_existing_binary` in `atomorphif*` functions, with fallback to `String.to_binary`
- Credo for linting
- A lot of documentation
- This file

### Changed
- use `String.to_existing_atom` in `atomorphif*` functions, with fallback to `String.to_atom`
