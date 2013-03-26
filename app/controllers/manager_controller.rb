class ManagerController < ApplicationController
  authorize_resource :class => false
  
  def index

    respond_to do |format|
      format.html
    end
  end
end
