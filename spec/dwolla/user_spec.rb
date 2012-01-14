require 'spec_helper'

describe Dwolla::User do
  let(:oauth_token) { 'valid_token' } 
  let(:token_param) { "oauth_token=#{oauth_token}" }

  describe "fetching your full account information" do
    before do
      stub_get('/oauth/rest/users', token_param).
        to_return(:body => fixture("account_information.json"))
    end

    it "should request the correct resource" do
      user = Dwolla::User.me(oauth_token).fetch

      a_get('/oauth/rest/users', token_param).should have_been_made
    end

    it "should return full information" do
      user = Dwolla::User.me(oauth_token).fetch

      user.should be_a Dwolla::User
      user.id.should == '812-111-1111'
      user.name.should == 'Test User'
      user.latitude.should == 41.584546
      user.longitude.should == -93.634167
      user.city.should == 'Des Moines'
      user.state.should == 'IA'
      user.type.should == 'Personal'
      user.oauth_token.should == oauth_token
    end
  end

  it "knows his balance" do
    stub_get('/oauth/rest/balance', token_param).
      to_return(:body => fixture("balance.json"))

    user = Dwolla::User.me(oauth_token)
    user.balance.should == 55.76
  end

  describe "contacts" do
    it "should request the correct resource when unfiltered" do
      user = Dwolla::User.me(oauth_token)

      stub_get('/oauth/rest/contacts', token_param).
        to_return(:body => fixture("contacts.json"))

      user.contacts

      a_get('/oauth/rest/contacts', token_param).should have_been_made
    end

    it "should request the correct resource when seaching by name" do
      user = Dwolla::User.me(oauth_token)

      stub_get("/oauth/rest/contacts?search=Bob&#{token_param}").
        to_return(:body => fixture("contacts.json"))

      user.contacts(:search => 'Bob')

      a_get("/oauth/rest/contacts?search=Bob&#{token_param}").should have_been_made
    end

    it "should request the correct resource when filtering by type" do
      user = Dwolla::User.me(oauth_token)

      stub_get("/oauth/rest/contacts?type=Facebook&#{token_param}").
        to_return(:body => fixture("contacts.json"))

      user.contacts(:type => 'Facebook')

      a_get("/oauth/rest/contacts?type=Facebook&#{token_param}").should have_been_made
    end

    it "should request the correct resource when limiting" do
      user = Dwolla::User.me(oauth_token)

      stub_get("/oauth/rest/contacts?limit=2&#{token_param}").
        to_return(:body => fixture("contacts.json"))

      user.contacts(:limit => 2)

      a_get("/oauth/rest/contacts?limit=2&#{token_param}").should have_been_made
    end

    it "should request the correct resource when using all together" do
      user = Dwolla::User.me(oauth_token)

      stub_get("/oauth/rest/contacts?search=Bob&type=Facebook&limit=2&#{token_param}").
        to_return(:body => fixture("contacts.json"))

      user.contacts(:search => "Bob", :type => "Facebook", :limit => 2)

      a_get("/oauth/rest/contacts?search=Bob&type=Facebook&limit=2&#{token_param}").should have_been_made
    end

    it "should return the contact users info properly" do
      user = Dwolla::User.me(oauth_token)

      stub_get("/oauth/rest/contacts", token_param).
        to_return(:body => fixture("contacts.json"))

      contacts = user.contacts

      first_contact = contacts.first

      first_contact.should be_a Dwolla::User
      first_contact.id.should == "12345"
      first_contact.name.should == "Ben Facebook Test"
      first_contact.image.should == "https://graph.facebook.com/12345/picture?type=square"
      first_contact.contact_type.should == "Facebook"

      second_contact = contacts.last

      second_contact.should be_a Dwolla::User
      second_contact.id.should == "812-111-1111"
      second_contact.name.should == "Ben Dwolla Test"
      second_contact.image.should == "https://www.dwolla.com/avatar.aspx?u=812-111-1111"
      second_contact.contact_type.should == "Dwolla"
    end
  end
end