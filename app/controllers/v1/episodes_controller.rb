module V1
    class EpisodesController < ApplicationController
        public
            def index
                rawSearchTerms = ""
                searchTermsArr = []
                searchTime = DateTime.now
                loggingEnabled = false

                @episodes = Episode.all

                if params[:series_number]
                    seriesNumberParam = params[:series_number].to_s
                    queryString = "episode_json -> 'series_number' = '#{seriesNumberParam}'"

                    @episodes = @episodes.where(queryString)
                end

                if params[:episode_number]
                    episodeNumberParam = params[:episode_number].to_s
                    queryString = "episode_json -> 'episode_number' = '#{episodeNumberParam}'"

                    @episodes = @episodes.where(queryString)
                end

                if params[:title]
                    titleParam = params[:title]
                    queryString = "episode_json ->> 'title' = #{titleParam}"
                
                    @episodes = @episodes.where(queryString)
                end

                if params[:air_date]
                    airDateParam = params[:air_date]
                    queryString = "episode_json ->> 'air_date' = #{airDateParam}"

                    @episodes = @episodes.where(queryString)
                end

                if params[:guest]
                    guestParam = params[:guest]
                    queryString = "episode_json ->> 'guests' ILIKE '%#{guestParam}%'"

                    @episodes = @episodes.where(queryString)
                end

                if params[:car]
                    carParam = params[:car]
                    queryString = "episode_json ->> 'cars' ILIKE '%#{carParam}%'"

                    @episodes = @episodes.where(queryString)
                end

                if params[:feature]
                    featureParam = params[:feature]
                    queryString = "episode_json ->> 'features' ILIKE '%#{featureParam}%'"

                    @episodes = @episodes.where(featureParam)
                end
                
                if params[:host]
                    hostParam = params[:host]
                    queryString = "episode_json ->> 'hosts' ILIKE '%#{hostParam}%'"

                    @episodes = @episodes.where(hostParam)
                end

                if params[:summary]
                    summaryParam = params[:summary]
                    queryString = "episode_json ->> 'summary' ILIKE '%#{summaryParam}%'"

                    @episodes = @episodes.where(summaryParam)
                end
                
                if params[:meta]
                    metaParam = params[:meta]
                    queryString = "episode_json ->> 'meta' ILIKE '%#{metaParam}%'"

                    @episodes = @episodes.where(metaParam)
                end

                if params[:search]
                    searchParam = params[:search]

                    # Match strings in quotes as verbatim
                    verbatimSearchTermsArr = searchParam.scan(/"([^"]*)"/).flatten

                    verbatimSearchTermsArr.each do |verbatimSearchTerm|
                        queryStringArr = []
                        queryStringArr << "episode_json ->> 'series_number' ~* ?"
                        queryStringArr << " OR episode_json ->> 'episode_number' ~* ?"
                        queryStringArr << " OR episode_json ->> 'title' ~* ?"
                        queryStringArr << " OR episode_json ->> 'air_date' ~* ?"
                        queryStringArr << " OR episode_json ->> 'guests' ~* ?"
                        queryStringArr << " OR episode_json ->> 'cars' ~* ?"
                        queryStringArr << " OR episode_json ->> 'features' ~* ?"
                        queryStringArr << " OR episode_json ->> 'hosts' ~* ?"
                        queryStringArr << " OR episode_json ->> 'summary' ~* ?"
                        queryStringArr << " OR episode_json ->> 'meta' ~* ?"

                        queryStringParamsArr = queryStringArr.map { |queryString| "\\m#{verbatimSearchTerm}\\M" }

                        @episodes = @episodes.where(queryStringArr.join(), *queryStringParamsArr)

                        searchParam = searchParam.gsub(verbatimSearchTerm, "")
                    end

                    searchParam = searchParam.gsub("\"", "")
                    searchParam = searchParam.strip

                    # Build an array of terms split by whitespace (match as AND)
                    searchTermsArr = searchParam.split(" ")

                    searchTermsArr.each do |searchTerm|
                        queryStringArr = []
                        queryStringArr << "episode_json ->> 'series_number' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'episode_number' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'title' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'air_date' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'guests' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'cars' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'features' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'hosts' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'summary' ILIKE ?"
                        queryStringArr << " OR episode_json ->> 'meta' ILIKE ?"

                        queryStringParamsArr = queryStringArr.map { |queryString| "%#{searchTerm}%" }

                        @episodes = @episodes.where(queryStringArr.join(), *queryStringParamsArr)
                    end
                end

                if params[:logging]
                    loggingEnabled = params[:logging] == "1"
                end

                if loggingEnabled
                    log = Log.new
                    log.search_term = rawSearchTerms
                    log.search_time = searchTime
                    log.save
                end
        end
    end
end