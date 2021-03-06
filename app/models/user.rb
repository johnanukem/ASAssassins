require "twilio-ruby"
class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: {maximum: 50}, format: /[\w]+([\s]+[\w]+){1}+/
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 50},
					  format: { with: VALID_EMAIL_REGEX },
					  uniqueness: { case_sensitive: false }
				
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }
	validates :kill_code, presence: true, uniqueness: { case_sensitive: false}
	validates :phone_number, presence: true, 
				uniqueness: {case_sensitive: false }, 
				length: {minimum: 10, maximum: 10}
	def increaseKillCount
		if self.num_of_kills == nil
			self.update_attribute(:num_of_kills, 1) 
		else
			self.update_attribute(:num_of_kills, self.num_of_kills + 1)
		end
	end

	def begin_game
		@users = User.all
		linkedList = []
		@users.each do |user|
			name =  user.name
			linkedList.push(name)
		end
		linkedList = linkedList.shuffle
		linkedList.each_with_index do |user, index|
			currentUser = User.find_by(name: user)
			if user != linkedList[linkedList.size - 1]
				target = linkedList[index + 1]
				currentUser.update_attribute(:target, target)
			else
				target = linkedList[0]
				currentUser.update_attribute(:target, target)
			end
		end
		return linkedList
		
	end

	def select_new_target(currentUser, killedUser) 
		target = killedUser.target
		if currentUser.target == killedUser.name

			User.delete(killedUser)
			currentUser.update_attribute(:target, target)
			currentUser.increaseKillCount
			return target
		else
			userAffected = User.find_by(target: killedUser.name)
			User.delete(killedUser)
			userAffected.update_attribute(:target, target)
			currentUser.increaseKillCount
			return currentUser.target
		end
	end


end
