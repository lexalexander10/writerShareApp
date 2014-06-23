require 'bcrypt'

class User < ActiveRecord::Base

    include PublicActivity::Common

    has_many :user_friendships
    has_many :friends, :through => :user_friendships
    has_many :inverse_user_friendships, :class_name => "UserFriendship", :foreign_key => "friend_id"
    has_many :inverse_friends, :through => :inverse_user_friendships, :source => :user

    has_many :versions

    validates_presence_of :name, :email, :password, :password_confirmation
    validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    validates_uniqueness_of :email, :name

    has_attached_file :avatar, :styles => {:medium => "300x300>", :small => "150x150#", :thumb => "45x45#" }, 
    :storage => :s3,
    #:s3_credentials => "http://localhost:3000/config/s3.yml", #  #{Rails.root}
    #:path => "/images/:id/:style.:extension",
    :default_url => "/images/:style/missing.png"
    validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

    def password
        @password
    end

    def password=(new_password)
        @password = new_password
        self.password_digest = BCrypt::Password.create(new_password)
    end

    def authenticate(test_password)
        if BCrypt::Password.new(self.password_digest) == test_password
            self
        else
            false
        end
    end

    def self.search(search)
        search_condition = "%" + search + "%"
        find(:all, :conditions => ['title LIKE ? OR description LIKE ?', search_condition, search_condition])
    end

    def avatar_url(size)
        self.avatar.url(size)
        # .gsub('s3.amazonaws.com/', 's3-us-west-2.amazonaws.com/')
    end

end
