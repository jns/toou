class AdminController < ApplicationController

    layout 'admin'
    
    def index
        authorize :admin
    end

end
