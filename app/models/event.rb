class Event < ActiveRecord::Base

	belongs_to :organizer, :class_name => "User", :foreign_key 	=> 'organizer'
	has_many :user_event_balances, dependent: :destroy
	has_many :payments, dependent: :destroy
	has_many :purchases, dependent: :destroy
	has_many :users, through: :user_event_balances

	# The total balance of an event is the total amount of purchases for that event
	def update_total_balance
		self.update_attribute(:total_balance, self.purchases.sum('amount'))
		self.total_balance
	end

	# Set an event as closed so it can stop accepting purchases or payments anymore
	def close_event
    	self.update_attribute(:closed, true)
  end

	# Wrapper method to find the user_event_balance attached to a specific event and id
	def find_user_event_balance(user_id)
		self.user_event_balances.find_by_user_id(user_id)
	end

  # Method to determine the total amount paid by a user to the event
	def find_total_payments_made_by_user(user_id)
		sum = 0
		if !self.payments.find_all_by_user_id(user_id).nil?
			self.payments.find_all_by_user_id(user_id).each do |payment|
				sum += payment.amount
			end
		end
		sum
	end
end
