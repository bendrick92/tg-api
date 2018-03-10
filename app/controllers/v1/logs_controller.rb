module V1
    class LogsController < ApplicationController
        def index
            @logs = Log.all.order(search_time: :desc).last(100)
        end
    end
end
