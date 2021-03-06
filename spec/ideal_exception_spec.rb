require 'spec_helper'

describe IdealMollie::IdealException do
  context "#new_order" do
    it "should throw exception when no config is set" do
      VCR.use_cassette("new_order", :match_requests_on => [:ignore_query_param_ordering]) do
        config = IdealMollie::Config
        config.reset!
        expect { IdealMollie.new_order(1234, "exception test", "0031") }.
          to raise_error(IdealMollie::IdealException, /A fetch was issued without specification of 'partnerid'./)
      end
    end

    it "should throw an exception when a unknown account is specified" do
      config = IdealMollie::Config
      config.test_mode = false
      config.partner_id = 123465
      config.report_url = "http://example.org/report"
      config.return_url = "http://example.org/return"

      VCR.use_cassette("new_order", :match_requests_on => [:ignore_query_param_ordering]) do
        expect { IdealMollie.new_order(1234, "exception test", "0031") }.
          to raise_error(IdealMollie::IdealException, /This account does not exist or is suspended./)
      end
    end

    it "should throw an exception when a unknown profile key is specified" do
      config = IdealMollie::Config
      config.test_mode = false
      config.partner_id = 123456
      config.profile_key = "00000000"
      config.report_url = "http://example.org/report"
      config.return_url = "http://example.org/return"

      VCR.use_cassette("new_order", :match_requests_on => [:ignore_query_param_ordering]) do
        expect { IdealMollie.new_order(1234, "exception test", "0031") }.
          to raise_error(IdealMollie::IdealException, /A fetch was issued for an unknown or inactive profile./)
      end
    end
  end

  context "#check_order" do
    it "should raise an exception when a invalid transaction_id is asked" do
      config = IdealMollie::Config
      config.test_mode = false
      config.partner_id = 654321
      config.report_url = "http://example.org/report"
      config.return_url = "http://example.org/return"

      VCR.use_cassette("check_order", :match_requests_on => [:ignore_query_param_ordering]) do
        expect { IdealMollie.check_order("482d599bbcc7795727650330ad65fe9b") }.
          to raise_error(IdealMollie::IdealException, /This is an unknown order./)
      end
    end
  end
end
