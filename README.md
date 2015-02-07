# ECFS

ECFS helps you download and parse filings from the FCC's Electronic Comment Filing System.

This gem powers [ecfs.link](https://ecfs.link), which lets you search the FCC's ECFS with ease. That site is also [open source](https://github.com/adelevie/ezfs).

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
end.get
#=>
# returns an instance of `ECFS::Proceeding::ResultSet`, which is a subclass of `Hash`:
{
  "constraints"   => {
    "bureau_code"  => "WC", 
    "page_number"  => "1", 
    "per_page"     => "100"
  },
  "fcc_url"       => "http://apps.fcc.gov/ecfs/proceeding_search/execute?bureauCode=WC&pageNumber=1&pageSize=100",
  "current_page"  => 1,
  "total_pages"   => 16,
  "first_result"  => 1,
  "last_result"   => 100,
  "total_results" => 1504,
  "results"       => [
    {
      "docket_number" => "10-90",
      "bureau"        => "Wireline Competition Bureau",
      "subject"       => "In the Matter of Connect America Fund A National Brooadband Plan for Our Future High-Cost\r\nUniversal Service Support. .",
      "filings_in_last_30_days" => 182
    },
   {
      "docket_number" => "05-337",
      "bureau"        => "Wireline Competition Bureau",
      "subject"       =>
      "In the Matter of Federal -State Joint Board on Universal Service High-Cost Universal\r\nService Support.  .. .",
      "filings_in_last_30_days" => 102
    },
  #...
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

#### Fetch filings for a proceeding:

```ruby
proceeding = ECFS::Proceeding.find("12-375")
proceeding.fetch_filings!
proceeding["filings"]   # See Filings section below for sample responses
```

### Filings

#### Search for filings

```ruby
filings = ECFS::Filing.query.tap do |q|
  q.docket_number = "12-375" 
end.get
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

#### Working with filing documents

`ECFS::Filing#documents` returns an `Array` of `ECFS::Document` instances.

```ruby
document = filings.first.documents.first
pp document
#=> 
#<ECFS::Document:0x007fed7c95bf48
 @filing=
  {
    "name_of_filer"  => "Leadership Conference on Civil and Human Rights",
    "docket_number"  => "12-375",
    "lawfirm_name"   => "",
    "date_received"  => "2013-05-14T00:00:00.000Z",
    "date_posted"    => "2013-05-14T00:00:00.000Z",
    "exparte"        => true,
    "type_of_filing" => "NOTICE OF EXPARTE",
    "document_urls"  => [
      "http://apps.fcc.gov/ecfs/document/view?id=7022313561",
      "http://apps.fcc.gov/ecfs/document/view?id=7022313562",
      "http://apps.fcc.gov/ecfs/document/view?id=7022313563"
    ]
  },
 @pages=[#<ECFS::Document::Page @text=String, @page_number=1>],
 @url="http://apps.fcc.gov/ecfs/document/view?id=7022313561">
```

To get the text from a given document, you can use `ECFS::Document#full_text`.

You can also keep track of page numbers with `ECFS::Document#pages`, which returns an `Array` of `ECFS::Document::Page` instances. `ECFS::Document::Page#text` and `ECFS::Document::Page#page_number` are self-explanatory.

### Bulk Queries

None of this works (leaving here for posterity):

This has been a problem that's been bothering me for a while: ECFS filing pages won't create spreadsheets when a query returns more than 10,000 filings. A simple solution is to add date constraints to the query until you have a set of queries where each result set contains 10,000 or fewer filings.

I implemented a convenience method that make these queries for you:

```ruby
docket_number = "11-109"
query = ECFS::BulkFilingsQuery.new(docket_number)
filings = query.get
```

In the background, `ECFS::BulkFilingsQuery#get` will perform as many queries as necessary to retrieve all the filings for the given proceeding.

### SOLR Search

The FCC has a [SOLR search page](http://apps.fcc.gov/ecfs/solr/search) which is not limited to 10,000 results. The bad news is that each page of results is maxed out at twenty. So this is all scrapable, but every 20 results requires a new HTTP request. Nevertheless, here's how you can scrape it:

```ruby
filings = ECFS::SolrScrapeQuery.new.tap do |q|
  q.docket_number = '12-83'
end.get

p filings.first
#=> 

{
  'proceeeding'=>"12-83",
  'name_of_filer'=>"Media Bureau Policy Division",
  'type_of_filing'=>"PUBLIC NOTICE",
  'url'=>"http://apps.fcc.gov/ecfs/comment/view?id=6017027798",
  'date_recieved'=>"03/30/2012",
  'pages'=>10
}
```

Options:

```ruby
filings = ECFS::SolrScrapeQuery.new.tap do |q|
  q.docket_number = '12-83'
  
  # a minimum date, inclusive. mm/dd/yyyy
  q.received_min_date = '03/30/2012'
  
  # an after_scrape block
  q.after_scrape = Proc.new do |filings|
    p "Fetched asynchronyously: #{filings.length}"
  end
  # This is handy for large scrapes.
end.get
```

### Daily Releases

This feature parses these types of pages: http://transition.fcc.gov/Daily_Releases/Daily_Business/2014/db0917/.

The documents listed are PDFs, text files, and `.docx` files.

```ruby
releases = ECFS::DailyReasesQuery.new.tap do |q|
  q.month = '12'
  q.day   = '17'
  q.year  = '2014'
end.get

txt_urls = releases.txts
pdf_urls = releases.pdfs
docs_urls = releases.docxs

p txt_urls.first
#=> 
{
  title: "DA-14-1835A1.txt",
  url: "http://transition.fcc.gov/Daily_Releases/Daily_Business/2014/db1217//DA-14-1835A1.txt"
}
```

## Testing

```
$ bundle exec m
```

## Contact

If you've made it this far into the README/are using this gem, I'd like to hear from you! Email me at [github username] at [google's mail] dot com.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
