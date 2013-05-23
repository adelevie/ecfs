# ECFS

ECFS helps you download and parse filings from the FCC's Electronic Comment Filing System.

[![Build Status](https://travis-ci.org/adelevie/ecfs.png?branch=master)](https://travis-ci.org/adelevie/ecfs)

[![Gem Version](https://badge.fury.io/rb/ecfs.png)](http://badge.fury.io/rb/ecfs)

[![Code Climate](https://codeclimate.com/github/adelevie/ecfs.png)](https://codeclimate.com/github/adelevie/ecfs)

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

### Proceedings

#### Search for a proceeding

```ruby
proceedings = ECFS::Proceeding.query.tap to |q|
  q.bureau_code = "WC"  # Wireline Competition Bureau
  q.per_page    = "100" # Defaults to 10, maximum is 100
  q.page_number = "1"
end
#=>
# returns an instance of `ECFS::Proceeding::ResultSet`, which is a subclass of `Hash`:
{
  "constraints" => {
    "bureau_code" => "WC", 
    "page_number" => "1", 
    "per_page"    => "100"
  },
  "fcc_url"       => "http://apps.fcc.gov/ecfs/proceeding_search/execute?bureauCode=WC&pageNumber=1&pageSize=100",
  "current_page"  => 1,
  "total_pages"   => 16,
  "first_result"  => 1,
  "last_result"   => 100,
  "total_results" => 1504,
  "results"=> [
  # each result is an instance of `ECFS::Proceeding`, which is a subclass of `Hash`
    {
      "docket_number" => "10-90",
      "bureau"        => "Wireline Competition Bureau",
      "subject"       => "In the Matter of Connect America Fund A National Brooadband Plan for Our Future High-Cost\r\nUniversal Service Support. ."
    },
   {
      "docket_number" => "05-337",
      "bureau"        => "Wireline Competition Bureau",
      "subject"       => "In the Matter of Federal -State Joint Board on Universal Service High-Cost Universal\r\nService Support.  .. ."
    },
   {
      "docket_number" => "13-39",
      "bureau"        => "Wireline Competition Bureau",
      "subject"       => "Rural Call Completion"
    },
   {
      "docket_number" => "03-109",
      "bureau"        => "Wireline Competition Bureau",
      "subject"       => "In the Matter of Lifeline and Link-Up"
    },
   {
      "docket_number" => "07-135",
      "bureau"        => "Wireline Competition Bureau",
      "subject"       => "In the Matter of Establishing Just and Reasonable Rates for Local Exchange Carriers. ."
    },
    # ...
  ]
}
```

#### Get the next page of results:

```ruby
next_page = proceedings.next
#=>
{
  "constraints" => {
    "bureau_code" => "WC",
    "per_page"    => "100",
    "page_number" => "2" # automagically incremented the page number
  },
 "fcc_url"       => "http://apps.fcc.gov/ecfs/proceeding_search/execute?bureauCode=WC&pageSize=100&pageNumber=2",
 "current_page"  => 2,
 "total_pages"   => 16,
 "first_result"  => 101,
 "last_result"   => 200,
 "total_results" => 1504,
 "results"       => [
  # ... 
  ]
}
```
See `ECFS::ProceedingsQuery#constraints_dictionary` for a list of query options.

#### Fetch info about a proceeding from the results:

```ruby
proceeding = proceedings["results"].select {|p| p["docket_number"] == "12-375"}.first
proceeding.fetch_info!
pp proceeding
#=>
{
  "docket_number" => "12-375",
  "bureau"        => "Wireline Competition Bureau",
  "subject"       => "Implementation of the Pay Telephone Reclassification and Compensation Provisions of the Telecommunications Act of 1996 et al.",
  "bureau_name"   => "Wireline Competition Bureau",
  "prepared_by"   => "Aleta.Bowers",
  "date_created"  => "2012-12-26T00:00:00.000Z", # iso8601 string
  "status"        => "Open",
  "total_filings" => "292",
  "filings_in_last_30_days" => "58"
}
```

### Find a proceeding by docket number

```ruby
proceeding = ECFS::Proceeding.find("12-375")
#=>
{
  "docket_number" => "12-375",
  "bureau"        => "Wireline Competition Bureau",
  "subject"       => "Implementation of the Pay Telephone Reclassification and Compensation Provisions of the Telecommunications Act of 1996 et al.",
  "bureau_name"   => "Wireline Competition Bureau",
  "prepared_by"   => "Aleta.Bowers",
  "date_created"  => "2012-12-26T00:00:00.000Z",
  "status"        => "Open",
  "total_filings" => "292",
  "filings_in_last_30_days" => "58"
}
```

### Filings

#### Search for filings

```ruby
filings = ECFS::Filing.query.tap do |q|
  q.docket_number = "12-375" 
end
#=> 
[
  # Each result is instance of `ECFS::Filing`, which is a subclass of `Hash`
  {
    "name_of_filer"  => "Leadership Conference on Civil and Human Rights",
    "docket_number"  => "12-375",
    "lawfirm_name"   => "",
    "date_received"  => "2013-05-14T00:00:00.000Z",  # iso8601 string
    "date_posted"    => "2013-05-14T00:00:00.000Z", 
    "exparte"        => true,
    "type_of_filing" => "NOTICE OF EXPARTE",
    "document_urls"  => [
      "http://apps.fcc.gov/ecfs/document/view?id=7022313561",
      "http://apps.fcc.gov/ecfs/document/view?id=7022313562",
      "http://apps.fcc.gov/ecfs/document/view?id=7022313563"
    ]
  },
 {
    "name_of_filer"  => "The Leadership Conference on Civil and Human Rights",
    "docket_number"  => "12-375",
    "lawfirm_name"   => "",
    "date_received"  => "2013-05-13T00:00:00.000Z",
    "date_posted"    => "2013-05-13T00:00:00.000Z",
    "exparte"        => true,
    "type_of_filing" => "NOTICE OF EXPARTE",
    "document_urls"  => [
      "http://apps.fcc.gov/ecfs/document/view?id=7022313134"
    ]
  },
 # ...
]
```

See `ECFS::FilingsQuery#constraints_dictionary` for a list of query options.

## TODO

### Get filings from proceedings with > 10,000 filings

fcc.gov will only generate spreadsheets of up to ~10,000 rows. This gem should first be able to detect those pages and then use a strategy for dividing the results into chunks and recombining them into a single results array. Such strategies might include recursively dividing the results in half (by date) until all result-sets contain < 10,000 results.

### Show filings in last 30 days for proceedings search

Self explanatory

### Extract text from filing PDFs

For each url in `ECFS::Filing#['document_urls']`, download the PDF file, extract text and store in-memory as part of the `ECFS::Filing` instance. Each url will point to a document with multiple pages. Therefore it's probably best to create an `ECFS::Filing::Document` class. Each `ECFS::Filing` instance may have multiple `ECFS::Filing::Document` instances. These will be accessed by `ECFS::Filing#documents`. `ECFS::Filing::Document` will have `#pages` and `#full_text` methods. `#pages` will return an `Array` of `ECFS::Filing::Document::Page` instances. `Page` will have a `#text` method, which will return a plain text string of the page contents. `ECFS::Filing::Document#full_text` will just be a `map` and a `join(",")` of this method.

This code should get me (or you!) started:

```ruby
require "pdf-reader"
require 'open-uri'

io     = open(url)
reader = PDF::Reader.new(io)
reader.pages.each do |page|
  page.text
end
```

## Contact

If you've made it this far into the README/are using this gem, I'd like to hear from you! Email me at [github username] at [google's mail] dot com.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
