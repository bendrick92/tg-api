module V1
    class EpisodesController < ApplicationController
        def index
            @episodes = Episode.all

            if params[:search]
                searchSplit = params[:search].gsub(/\s+/m, '|')
                # SELECT "episodes".* FROM "episodes" WHERE (episode_json @> '{"series_number": "1"}')
                # SELECT "episodes".* FROM "episodes" WHERE (episode_json ? 'title')
                # SELECT * FROM episodes WHERE (episode_json -> 'title' ? 'Series 1, Episode 1')
                # SELECT * FROM episodes WHERE episode_json::text LIKE '%Pagani%'
                @episodes = @episodes.where(["episode_json::text SIMILAR TO ?", "%(#{searchSplit})%"])
            end
        end

        def show
            @episode = Episode.find(params[:id])
        end
    end
end