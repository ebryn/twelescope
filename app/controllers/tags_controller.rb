class TagsController < ApplicationController
  def index

  end

  def show
    @tag = '#'+params[:id]
    @user_taggings = Tagging.find_all_by_tag(@tag, :include => :user)
  end
end
