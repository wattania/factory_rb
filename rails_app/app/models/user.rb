class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :recoverable, 
  devise :database_authenticatable, #:registerable,
         :rememberable, :trackable,#, :validatable
         :lockable

  include FuncValidateHelper
  include FuncUpdateRecord

  validates :user_name, :first_name, presence: true
  validates :user_name, :email, uniqueness: true

  before_validation :func_set_uuid, on: :create
end
