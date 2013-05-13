# ECFS

ECFS helps you download and parse filings from the FCC's Electronic Comment Filing System.

[![Build Status](https://travis-ci.org/adelevie/ecfs.png?branch=master)](https://travis-ci.org/adelevie/ecfs)

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

```sh
$ gem install ecfs
```

## Usage

```ruby

# get info about a specific proceeding
proceeding = ECFS::ProceedingsQuery.new.tap do |q|
  q.eq("proceeding_number", "12-375")
end.get
#=>
{
  "bureau_name" => "Wireline Competition Bureau",
  "subject" => 
  "Implementation of the Pay Telephone Reclassification and Compensation Provisions of the Telecommunications Act of 1996 et al.",
  "prepared_by" => "Aleta.Bowers",
  "date_created" => "12/26/2012",
  "status" => "Open",
  "total_filings" => "292",
  "filings_in_last_30_days" => "58"
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
