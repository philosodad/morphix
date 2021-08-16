# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## v0.8.1 - 2020-09-19
### Fixed
- Binary keys causing crashes in the atomorphif* family of methods. Binary keys that cannot be tranformed to atoms will be ignored. (Issue #24)

### Removed
- Support for Elixir versions before 1.7.4

## v0.8.0 - 2020-06-01
### Added
- checks for Kernel.is_struct() for compatibility with Elixir 1.10+

## v0.7.0 - 2019-04-10
### Added
- added morphiform!

## v0.6.0 - 2019-01-13
### Added
- added stringmorphiform!
- added stringmorphify!

## v0.5.0 - 2018-12-08
### Added
- added equaliform?
- added equalify?

### Changed
- updated documentation

## v0.4.0 - 2018-10-15
### Changed
- compactify and compactiform now remove nil elements from lists

## v0.3.0 - 2018-04-15
### Changed
- Partiphify now uses `chunk_every` instead of deprecated `Enum.chunk` method
- Version pinned at 1.6+ because of test incompatibilities between 1.5 and 1.6

## v0.2.4 - 2018-04-15
### Changed
- Elixir version locked to be >= 1.4 and < 1.6. 1.6+ contains changes to the `String.split` version that breaks tests.

## v0.2.1 - 2017-12-22
### Changed
- fixed bug where struct types are recursed in atomorphiform

## v0.2.0 - 2017-12-19
### Added
- added atomorphify!
- added atomorphiform!

### Changed
- fixed error with empty lists in atomorphif* methods
- updated documentation
- improved testing

## v0.1.0 - 2017-11-22
### Added
- added `partiphify/2` function for partitioning lists

### Changed
- several functions now return `%BadMapError{}` instead of function undefined errors.

## v0.0.8 - 2017-11-15
### Added
- added partiphify! function for partitioning lists

## v0.0.7 - 2017-06-29
### Added
- added compactify and compactiform functions for eliminating nil values from maps.

## v0.0.4 - 2016-12-17
### Added
- added `:safe` option for `atomorphif*` functions, if used, only existing atoms will be used in string conversion.

### Changed
- `atomorphif*` functions do not use `String.to_existing_atom` unless `:safe` option is passed.

## v0.0.3 - 2016-12-13
### Added
- `morphify!` and `morphify` functions
- `morphiflat!`
- use `String.to_existing_binary` in `atomorphif*` functions, with fallback to `String.to_binary`
- Credo for linting
- A lot of documentation
- This file

### Changed
- use `String.to_existing_atom` in `atomorphif*` functions, with fallback to `String.to_atom`
