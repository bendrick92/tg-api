module V1
    class EpisodesController < ApplicationController
        def index
            @episodes = Episode.all

            if params[:search]
                @episodes = @episodes.where(["LOWER(episode_json::text) LIKE LOWER(?)", "%#{params[:search]}%"])
            end
        end

        def show
            @episode = Episode.find(params[:id])
        end
    end
end