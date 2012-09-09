class AuthorizationsController < ApplicationController
	def show
		authorization = Authorization.find_by_state(params[:id])
		
		if authorization
		  render :status => :ok, :json => authorization
	  else
	    render :status => :ok, :json => { :error => 'Authorization not found' }
    end
	end
	
	def create
	  code = params[:code]
	  error = params[:error]
	  state = params[:state]
	  authorization = Authorization.new(:state => state)
	  
	  if code
	    begin
	      authorization.token = Authorization.get_token_from_code code
      rescue Exception => e
        authorization.error = e.message
      end
	  elsif error
	    authorization.error = error
    else
      authorization.error = "facebook_error"
    end
    
    begin
      authorization.save!
    rescue Exception => e
      logger.error "Error saving Authorization: #{e.class}:#{e.message}. BACKTRACE: #{e.backtrace}"
    end
    
    respond_to do |format|
      format.html
    end
	end
end
