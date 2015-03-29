# ECFS

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecfs'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```
$ gem install ecfs
```

## Usage

```ruby
filings = ECFS::Filings.search docket: '14-261', size: 1000, start: 1000
#=>
[
  {},
  {},
  {}
]
```

```ruby
filing = ECFS::Filings.search(docket: '14-261', size: 1000, start: 1000).first
ECFS::Filings.get_text(filing[:url])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ecfs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
