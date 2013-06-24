require 'spec_helper'

describe IdealMollie::OrderResult do
  before(:each) do
    @config = IdealMollie::Config
    @config.reset!
    @config.test_mode = false
    @config.partner_id = 987654
    @config.report_url = "http://example.org/report"
    @config.return_url = "http://example.org/return"
  end

  describe '#serialize' do
    it 'serializes all values for a succesful order' do
      VCR.use_cassette("check_order", :match_requests_on => [:ignore_query_param_ordering]) do
        order_result = IdealMollie.check_order("482d599bbcc7795727650330ad65fe9b")

        expected_serialized_result = {
          :amount => 1000,
          :transaction_id => "482d599bbcc7795727650330ad65fe9b",
          :amount => 1000,
          :currency => "EUR",
          :paid => true,
          :message => "This iDEAL-order has successfuly been payed for, and this is the first time you check it.",
          :customer_name => "Hr J Janssen",
          :customer_account => "P001234567",
          :customer_city => "Amsterdam"
        }

        order_result.serializable_hash.should eq expected_serialized_result
      end
    end

    it 'serializes all values for a unsuccesful order' do
      VCR.use_cassette("check_order", :match_requests_on => [:ignore_query_param_ordering]) do
        order_result = IdealMollie.check_order("c9f93e5c2bd6c1e7c5bee5c5580c6f83")

        expected_serialized_result = {
          :amount => 1000,
          :transaction_id => "c9f93e5c2bd6c1e7c5bee5c5580c6f83",
          :amount => 1000,
          :currency => "EUR",
          :paid => false,
          :message => "This iDEAL-order wasn't payed for, or was already checked by you. (We give payed=true only once, for your protection)",
          :customer_name => nil,
          :customer_account => nil,
          :customer_city => nil
        }

        order_result.serializable_hash.should eq expected_serialized_result
      end
    end
  end
end
