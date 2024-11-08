class Comment < ApplicationRecord
  belongs_to :post,   dependent: :destroy

  validates :name,    presence: true 
  validates :content,  presence: true
end
