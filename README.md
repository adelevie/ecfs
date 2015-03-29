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

### Filings

Get a list of filings given a docket number:

```ruby
filings = ECFS::Filings.search(docket: '14-57')
#=>
[
  {
    :docket=>"14-57",
    :filer=>"Media Bureau",
    :url=>"http://apps.fcc.gov/ecfs/comment/view?id=6017610890",
    :lawfirm=>"FCC",
    :received=>"2014-04-04T00:00:00-04:00",
    :posted=>"2014-04-04T14:00:29-04:00",
    :exparte=>"No",
    :type=>"ORDER",
    :pages=>10
  },
  #...
}
```

By default, `ECFS::Filings::search` will fetch up to 1000 filings in ascending order by data. However you can supply your own parameters:

```ruby
filings1 = ECFS::Filings.search(docket: '14-57', size: 500, start: 0)
filings2 = ECFS::Filings.search(docket: '14-57', size: 500, start: 500)
filings3 = ECFS::Filings.search(docket: '14-57', size: 1000, start: 0)
filings1 + filings2 == filings3 #=> true
```

Get filings in descending order (e.g. gets you the most recent):

```ruby
filings = ECFS::Filings.search(docket: '14-57', order: 'desc')
```

#### Fetching document links

The `:url` in a filings hash points to a filing that could contain multiple documents ([example](http://apps.fcc.gov/ecfs/comment/view?id=60001016691)).

To programatically get the links to all documents from that filing:

```ruby
links = ECFS::Filings.get_document_links(url: 'http://apps.fcc.gov/ecfs/comment/view?id=60001016691')
#=>
[
  "http://apps.fcc.gov/ecfs/document/view?id=60001029567", "http://apps.fcc.gov/ecfs/document/view?id=60001029568"
]
```

### Proceedings

Get information about a proceeding given a docket number:

```ruby
proceeding = ECFS::Proceedings.search(docket: '14-57')
#=>
{
  :bureauname=>"Media Bureau",
  :subject=>
  "Applications of Comcast Corporation and Time Warner Cable Inc. for Consent to Assign or Transfer Control of Licenses and Applications",
  :preparedby=>"Robin.Minor",
  :datecreated=>"2014-04-04 13:08:57.993",
  :status=>"Open",
  :totalfilings=>"100697",
  :filingsinlast30days=>"139"
}
```

### EDOCS

Provides a few ways to get documents published by the FCC.

#### Given a docket number

```ruby
docs = ECFS::EDOCS.search(docket: '14-261')
#=>
[
  {
    :title=>"Promoting Innovation and Competition in the Provision of Multichannel Video Programming Distribution Services",
    :released=>"03/11/2015",
    :description=>"Granted the request for extension of the reply comment deadline",  :word=>["https://apps.fcc.gov/edocs_public/attachmatch/DA-15-314A1.doc"],  :pdf=>["https://apps.fcc.gov/edocs_public/attachmatch/DA-15-314A1.pdf"],  :txt=>["https://apps.fcc.gov/edocs_public/attachmatch/DA-15-314A1.txt"]
  },
 # ...
]
```

### Given an FCC Record citation

```ruby
docs = ECFS::EDOCS.search(fcc_rcd_vol: '16', fcc_rcd_page: '20341')
#=>
[
  {
    :title=>"PACIFIC WIRELESS TECHNOLOGIES, INC. AND NEXTEL OF CALIFORNIA",
    :released=>"11/16/2001",
    :description=>"Granted application of Pacific Wireless Technologies to assign its licenses to Nextel of Calfornia, Inc.",  :word=>["https://apps.fcc.gov/edocs_public/attachmatch/DA-01-2685A1.doc"],  :pdf=>["https://apps.fcc.gov/edocs_public/attachmatch/DA-01-2685A1.pdf"],  :txt=>["https://apps.fcc.gov/edocs_public/attachmatch/DA-01-2685A1.txt"]
  }
]
```

### Parsing footnotes

You can get machine-readable access to an EDOCS document's footnotes with a URL to its `:word` version. E.g.:

```ruby
docs = ECFS::EDOCS.search(docket: '14-261')
doc = docs[3]
word_url = doc[:word].first
footnotes = ECFS::Util.get_footnotes(url: word_url)
#=>
[
  {
    :index=>1,
    :text=>
   "We see daily news that cable operators and satellite television providers are obtaining rights for online distribution of content.  Sam Adams and Christian Plumb, Verizon CEO says to launch Web TV product in 2015, Reuters, September 11, 2014, available at http://www.reuters.com/article/2014/09/11/us-verizon-comms-towers-idUSKBN0H61KB20140911 (reporting that Sony, Dish Network, DIRECTV and Verizon are each developing Internet-delivered streaming video services that are a “viable alternative to cable TV service.”); Edmund Lee, Scott Moritz and Alex Sherman, Dish Leads in Race to Offer Online TV to Compete With Cable, Bloomberg, March 15, 2014, available at http://www.bloomberg.com/news/2014-03-04/dish-takes-lead-in-race-to-offer-streaming-tv-to-rival-cable.html (“If Dish goes ahead with an online service, competitors could follow -- including cable companies like Comcast and Cablevision Systems Corp., which could move out of their traditional regions to offer TV nationwide, said Bernard Gershon, a digital media consultant in New York.”); Chris Young, Industry awaits linear OTT experiment, SNL Kagan, July 18, 2014, available at http://www.snl.com/interactivex/article.aspx?id=28627040&KPLT=2; Comcast branches out cloud DVR, live streaming service, CED Magazine, May 8, 2014, available at http://www.cedmagazine.com/news/2014/05/comcast-branches-out-cloud-dvr-live-streaming-service (“Like other video service providers, Comcast is focused on offering live streaming out of the home.”).  AT&T’s U-Verse service is delivered via Internet Protocol (“IP”) today.  See AT&T, What is IPTV? (2009), available at https://www.att.com/Common/about_us/files/pdf/IPTV_background.pdf.  In recognition of the increasing prevalence of Internet distribution of video, the National Cable & Telecommunications Association has renamed its annual Cable Show as INTX: the Internet and Television Expo, “in an effort to broaden the three-day gathering to include online video providers and distributors beyond the traditional Cable Show crowd.”  Kent Gibbons, NCTA: ‘Cable Show’ Convention Becoming INTX, Multichannel News (Sept. 17, 2014), http://www.multichannel.com/ncta-cable-show-convention-becoming-intx/383922."},
 {
   :index=>2,
   :text=>
   "For readability throughout this NPRM, we use the term “Internet-delivered” to refer to any service delivered using IP whether or not it uses the public Internet, except for cable service.  See infra ¶ 71."
 },
 # ...
]
```

#### Counting Ids

In citations, especially legal citations, the ["Idem"](http://en.wikipedia.org/wiki/Idem) is used to point to the previous citation. If you want to know how many "children" a given footnote has (e.g. which citations reference it with "Id.") pass `id_tree: true` to `ECFS::Util::get_footnotes`:

```ruby
url = "https://apps.fcc.gov/edocs_public/attachmatch/FCC-14-210A1.docx"
footnotes = ECFS::Util.get_footnotes(url: url, id_tree: true)
footnotes.select {|fn| fn[:ids].length > 0}
#=>
[
  {
    :index=>270,
    :text=>
    "U.S. Census Bureau, 2007 Economic Census.  See U.S. Census Bureau, American FactFinder, “Information: Subject Series – Estab and Firm Size: Employment Size of Establishments for the United States: 2007 – 2007 Economic Census,” NAICS code 517110, Table EC0751SSSZ2; available at http://factfinder2.census.gov/faces/nav/jsf/pages/index.xhtml.",
    :ids=>[
      {:index=>271, :text=>"Id.", :ids=>[], :id=>true}
    ],
    :id=>false
  },
  # ...
}
```

If you were so inclined, you could quickly find all idem footnotes:

```ruby
footnotes.select {|fn| fn[:id] == true}
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
