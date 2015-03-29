require 'spec_helper'

#describe ECFS, vcr: {record: :all, match_requests_on: [:body, :query, :method]} do
describe ECFS do
  it 'has a version number' do
    expect(ECFS::VERSION).not_to be nil
  end

  describe ECFS::EDOCS do
    context 'basic form submit' do

      it 'searches given a docket number' do
        docs = ECFS::EDOCS.search(docket: '14-261')

        expect(docs).to(be_a(Array))
        expect(docs.first).to(be_a(Hash))
        expect(docs.first).to(have_key(:title))
        expect(docs.first).to(have_key(:released))
        expect(docs.first).to(have_key(:description))
        expect(docs.first).to(have_key(:word))
        expect(docs.first).to(have_key(:pdf))
        expect(docs.first).to(have_key(:txt))
      end

      it 'searches the FCC Record' do
        docs = ECFS::EDOCS.search(fcc_rcd_vol: '16', fcc_rcd_page: '20341')

        expect(docs).to(be_a(Array))
        expect(docs.first).to(be_a(Hash))
        expect(docs.first).to(have_key(:title))
        expect(docs.first).to(have_key(:released))
        expect(docs.first).to(have_key(:description))
        expect(docs.first).to(have_key(:word))
        expect(docs.first).to(have_key(:pdf))
        expect(docs.first).to(have_key(:txt))
      end
    end
  end

  describe ECFS::Filings do
    context 'fetching filings links' do
      let(:url) { 'http://apps.fcc.gov/ecfs/comment/view?id=6017611775' }

      it 'fetches filing links given a filing url' do
        links = ECFS::Filings.get_document_links(url)

        expect(links).to(be_a(Array))
      end
    end

    context 'basic scrape' do
      let(:docket) { '14-57' }

      it 'has a search method' do
        expect(ECFS::Filings).to(respond_to(:search))
      end

      it 'scrapes filings' do
        size = 1000
        filings = ECFS::Filings.search docket: docket, size: size, start: 0

        expect(filings.length).to(eq(size))
      end

      it 'pages through filings' do
        filings1 = ECFS::Filings.search docket: docket, size: 50, start: 0
        filings2 = ECFS::Filings.search docket: docket, size: 50, start: 50
        filings3 = ECFS::Filings.search docket: docket, size: 100, start: 0

        expect(filings1+filings2).to(eq(filings3))
      end
    end
  end
end
