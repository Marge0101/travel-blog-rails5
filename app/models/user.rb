class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token,:reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  has_many :microposts,dependent: :destroy
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  has_many :favorites
  has_many :favorites_microposts, through: :favorites, source: :micropost
  
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def favorite(micropost)
      self.favorites.find_or_create_by(micropost_id: micropost.id)
  end

  def unfavorite(micropost)
    favorites = self.favorites.find_by(micropost_id: micropost.id)
    favorites.destroy if favorites
  end

  def favorite?(micropost)
    self.favorites_microposts.include?(micropost)
  end
  
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  
  #def authenticated?(remember_token)
    #return false if remember_digest.nil?
    #BCrypt::Password.new(remember_digest).is_password?(remember_token)
  #end
 
  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end
  
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end
  
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  private
  
  # Converts email to all lower-case.
  def downcase_email
      self.email = email.downcase
  end
  
  # Creates and assigns the activation token and digest.
  def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
  end
end
