class LoginsController < ApplicationController

def new
	add_breadcrumb "Login", :log_in_path
	@title = "Login"
	
end

def create
#byebug
	user = User.authenticate(params[:username], params[:password])
	if user
		session[:user_id] = user.id
		redirect_to homes_path, :login => "Logged in!"
	else
		flash[:login] = "Invalid username or password"
		render "new"
	end
end

def destroy
	session[:user_id] = nil
	redirect_to homes_path, :notice_out => "Logged out!"

end

end