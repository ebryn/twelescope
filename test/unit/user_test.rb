#require "test_helper"
require File.expand_path( File.dirname(__FILE__)) + '/../test_helper'
#require 'models'

class UserTest < Test::Unit::TestCase
  context "User" do
    setup do
      @user = User.new
    end
    subject { @user }

    should "provide a twitter id as their param" do
      @user.twitter_name = "schmoe"
      @user.to_param.should == "schmoe"
    end

    should_have_many :friendships
    should_have_many :friends
    should_have_many :linkages
    should_have_many :links
    should_have_many :domains

    context "popularity" do
      setup do
        @user.twitter_followers_count = 100
        @user.save
        @user2 = User.create :twitter_name => "blah", :twitter_followers_count => 100
      end

      should "return more popular users first" do
        User.popular.first.should == @user
      end
    end

    should_respond_to :enqueueable?, :enqueue

    context "link creation" do
      setup do
        @example_url = "http://example.com/test1"
        @expanded_url = "http://example.com/expanded"
        @link = Link.create :url => @expanded_url
        @action = lambda { @user.add_linkages @example_url }
      end

      should "review existing shortlinks" do
        Linkage.expects(:find_by_shared_url).with(@example_url, :include => :link )
        @action.call
      end

      should "not create a link if a shortlink exists" do
        Linkage.create :shared_url => @example_url, :link => @link
        Link.expects(:find_or_create_by_url).times(0)
        @action.call
      end

      should "create a link if no shortlink exists" do
        Linkage.delete_all
        Link.expects(:find_or_create_by_url).times(1)
        @action.call
      end

      should "add links" do
        @action.call
        @user.save
        @user.linkages.first.shared_url.should == @example_url
        @user.linkages.first.link.should_not be_nil
        @user.links(true).first.url.should == @example_url
      end
    end

    context "queue priority" do
      setup do
        @friend = User.new :twitter_name => "blah"
        @visitor = User.new :twitter_name => "beter", :site_visitor => true
      end

      should "set visitors as high priority" do
        @visitor.queue_priority.should == 10
      end
      should "set friends as normal priority" do
        @friend.queue_priority.should == 5
      end
    end
  end
end
