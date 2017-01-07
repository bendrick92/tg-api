module V1
    class EpisodesController < ApplicationController
        def index
            rawSearchTerms = ""
            searchTermsArr = []
            searchTime = DateTime.now
            loggingEnabled = true

            @episodes = Episode.all

            if params[:search]
                rawSearchTerms = params[:search]
                searchTerms = rawSearchTerms

                # Match strings in quotes as verbatim
                verbatimSearchTermsArr = searchTerms.scan(/"([^"]*)"/).flatten
                verbatimSearchTermsArr.each do |verbatimSearchTerm|
                    @episodes = @episodes.where("episode_json::text ~* ?", "\\m#{verbatimSearchTerm}\\M")

                    # Remove to prevent duplicate parsing
                    searchTerms = searchTerms.gsub(verbatimSearchTerm, "")
                end

                # Cleanse input
                searchTerms = searchTerms.gsub("\"", "")
                searchTerms = searchTerms.strip

                # Build an array of terms split by whitespace (match as AND)
                searchTermsArr = searchTerms.split(" ")

                searchTermsArr.each_with_index do |searchTerm, index|
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

                    queryStringParamsArr = queryStringArr.map { |queryString| "%" + searchTerm + "%" }

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
                #log.save
            end
        end

        def show
            @episode = Episode.find(params[:id])
        end

        private
            def getAllDictionaries
                return Dictionary.all
            end

            def getAllRelatedTerms
                allRelatedTerms = []
                allDictionaries = getAllDictionaries

                allDictionaries.each do |dictionary|
                    relatedTerms = dictionary.related_terms.split(",")
                    allRelatedTerms.concat relatedTerms
                end

                return allRelatedTerms
            end

            def containsRelatedTerm(input)
                allRelatedTerms = getAllRelatedTerms

                allRelatedTerms.each do |relatedTerm|
                    if input.include? relatedTerm
                        return true
                    end
                end

                return false
            end

            def extractRelatedTerm(input)
                allRelatedTerms = getAllRelatedTerms

                allRelatedTerms.each do |relatedTerm|
                    if input.include? relatedTerm
                        return relatedTerm
                    end
                end

                return ""
            end
    end
end