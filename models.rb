require './helpers'
require 'sequel'
require 'securerandom'

DB = Sequel.connect 'postgres://bblog:bblog@localhost:5432/bblog'
DB.extension :pagination


class User < Sequel::Model
  include Security
  one_to_many :posts
  one_to_many :comments
  
  def before_create
    super
    self.uuid = generate_uuid
    self.salt = generate_uuid
    self.created_at = DateTime.now
  end   
  
  def set_password(plaintext)
    self.update(password: encrypt(email, plaintext, salt))
  end
  
  def generate_session
    Session.create uuid: generate_uuid, user: self
  end
  
  def valid_password?(plaintext)
    enc = encrypt(email, plaintext, salt)
    enc == password
  end

  def to_json(*a)
    {name: name, email: email}.to_json
  end
  

end

class Session < Sequel::Model
  include Security
  many_to_one :user
  def before_create
    super
    self.uuid = generate_uuid
    self.created_at = DateTime.now
  end   
end

class Post < Sequel::Model
  include Security
  many_to_one :user
  one_to_many :comments
  
  def before_create
    super
    self.uuid = generate_uuid
    self.created_at = DateTime.now
  end   
  
  
end

class Comment < Sequel::Model
  include Security
  many_to_one :user
  many_to_one :comment

  def before_create
    super
    self.uuid = generate_uuid
    self.created_at = DateTime.now
  end   
  
  
end
