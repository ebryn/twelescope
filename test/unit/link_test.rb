require File.expand_path( File.dirname(__FILE__)) + '/../test_helper'

class LinkTest < Test::Unit::TestCase

  context "Link" do
    setup do
      @link = Link.create :url => "http://bit.ly/3aIiw7"
    end

    context "expanding urls" do
      setup do
        @link.expand_url
      end
      should "set the domain name" do
        @link.domain_name.should == "museumtwo.blogspot.com"
      end

      should "create a domain" do
        @link.domain.name.should == "museumtwo.blogspot.com"
      end

      context "expanding urls when the domain is set" do
        setup do
          @link.domain = Domain.create :name => "bitly.com"
          @link.domain_name = "bitly.com"
          @link.expand_url
        end
        should "set the domain name" do
          @link.domain_name.should == "museumtwo.blogspot.com"
        end

        should "create a domain" do
          @link.domain.name.should == "museumtwo.blogspot.com"
        end

        should "mark as followed" do
          @link.followed.should be_true
        end
      end
    end

    content "in the queue" do

    end
  end

end
