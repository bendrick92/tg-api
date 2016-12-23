module V1
    class EpisodesController < ApplicationController
        def index
            searchTerm = ""
            searchTime = DateTime.now

            @episodes = Episode.all

            if params[:search]
                searchTerms = params[:search].split(",")

                searchTerms.each do |searchTerm|
                    @episodes = @episodes.where(["LOWER(episode_json::text) LIKE LOWER(?)", "%#{searchTerm}%"])
                end
            end

            log = Log.new
            log.search_term = searchTerm
            log.search_time = searchTime
            log.save
        end

        def show
            @episode = Episode.find(params[:id])
        end
    end
end