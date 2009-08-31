class Tagging < ActiveRecord::Base
  belongs_to :user

  def self.extract_tags(text)
    text.scan(/(?:^| )(#[^, ]+)/).flatten
  end
end
