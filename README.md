# ECFS

ECFS helps you download and parse filings from the FCC's Electronic Comment Filing System.

[![Build Status](https://travis-ci.org/adelevie/ecfs.png?branch=master)](https://travis-ci.org/adelevie/ecfs)

[![Gem Version](https://badge.fury.io/rb/ecfs.png)](http://badge.fury.io/rb/ecfs)

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

### Get info about a proceeding

```ruby
proceeding = ECFS::ProceedingsQuery.new.tap do |q|
  q.eq("docket_number", "12-375")
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

### Get filings

```ruby
filings = ECFS::FilingsQuery.new.tap do |q|
  q.eq("docket_number", "12-375")
end.get
#=> 
[
  {
    "name_of_filer"=>"Leadership Conference on Civil and Human Rights",
    "docket_number"=>"12-375",
    "lawfirm_name"=>"",
    "date_received"=>"2013-05-14",
    "date_posted"=>"2013-05-14",
    "exparte"=>true,
    "type_of_filing"=>"NOTICE OF EXPARTE",
    "document_urls"=>
     ["http://apps.fcc.gov/ecfs/document/view?id=7022313561",
      "http://apps.fcc.gov/ecfs/document/view?id=7022313562",
      "http://apps.fcc.gov/ecfs/document/view?id=7022313563"]
  },
 {
    "name_of_filer"=>"The Leadership Conference on Civil and Human Rights",
    "docket_number"=>"12-375",
    "lawfirm_name"=>"",
    "date_received"=>"2013-05-13",
    "date_posted"=>"2013-05-13",
    "exparte"=>true,
    "type_of_filing"=>"NOTICE OF EXPARTE",
    "document_urls"=>["http://apps.fcc.gov/ecfs/document/view?id=7022313134"]
  },
 {
   "name_of_filer"=>"David J. Hodges",
    "docket_number"=>"12-375",
    "lawfirm_name"=>"",
    "date_received"=>"2013-04-30",
    "date_posted"=>"2013-05-10",
    "exparte"=>false,
    "type_of_filing"=>"LETTER",
    "document_urls"=>["http://apps.fcc.gov/ecfs/document/view?id=7022312052"]
  },
 {
   "name_of_filer"=>"Frederick Trons",
    "docket_number"=>"12-375",
    "lawfirm_name"=>"",
    "date_received"=>"2013-04-29",
    "date_posted"=>"2013-05-10",
    "exparte"=>false,
    "type_of_filing"=>"LETTER",
    "document_urls"=>["http://apps.fcc.gov/ecfs/document/view?id=7022312047"]
  },
# ...
}
```

See `ECFS::FilingsQuery#constraints_dictionary` for a list of query options.

## TODO

### Parse proceeding search results

If you enter a docket number, you'll get info about that specific proceeding. If you enter other search terms (sans docket number), fcc.gov returns a results page of proceeding listings. This gem should be able to page through and parse these results. See `ECFS::ProceedingsQuery.constraints_dictionary` for a list of potential query options.

### Get filings from proceedings with > 10,000 filings

fcc.gov will only generate spreadsheets of up to ~10,000 rows. This gem should first be able to detect those pages and then use a strategy for dividing the results into chunks and recombining them into a single results array.

### Typecasting dates

For now, dates scraped from fcc.gov are returned as "yyyy-mm-dd" strings. I'm not completely convinced, but perhaps returning Ruby `Date` objects is best.

### Syntax sugar

Something like this might be nice:

```ruby
ECFS::Proceeding.new("12-375").subject
```

## Contact

If you've made it this far into the README/are using this gem, I'd like to hear from you! Email me at [github username] at [google's mail] dot com.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
