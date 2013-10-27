class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	helper :all

	before_action :require_login

	private

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def require_login
		unless current_user
			flash[:error] = "You must be logged in to access this section"
			redirect_to log_in_url
		end
	end

	def get_users_in_event(event)
	    ret = Array.new
	    event.user_event_balances.each do |user_event_balance|
	     	ret << user_event_balance.user_id
	    end
	    return ret
  	end

  	helper_method :get_users_in_event

	helper_method :current_user
end
