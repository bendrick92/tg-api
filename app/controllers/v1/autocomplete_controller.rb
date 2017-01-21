module V1
    class AutocompleteController < ApplicationController
        public
            def index
                if params[:search]
                    @results = []

                    searchParam = params[:search].downcase

                    if params[:limit]
                        limitParam = params[:limit].to_i
                    else
                        limitParam = 5
                    end

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

                    queryStringParamsArr = queryStringArr.map { |queryString| "%#{searchParam}%" }

                    selectCols = ""
                    selectCols << "episode_json ->> 'series_number' AS series_number"
                    selectCols << ", episode_json ->> 'episode_number' AS episode_number"
                    selectCols << ", episode_json ->> 'title' AS title"
                    selectCols << ", episode_json ->> 'air_date' AS air_date"
                    selectCols << ", episode_json ->> 'guests' AS guests"
                    selectCols << ", episode_json ->> 'cars' AS cars"
                    selectCols << ", episode_json ->> 'features' AS features"
                    selectCols << ", episode_json ->> 'hosts' AS hosts"
                    selectCols << ", episode_json ->> 'summary' AS summary"
                    selectCols << ", episode_json ->> 'meta' AS meta"

                    matchedEpisodes = Episode.select(selectCols).where(queryStringArr.join(), *queryStringParamsArr).to_a

                    allTitles = matchedEpisodes.pluck("title")
                    allTitles.each do |title|
                        if !isNilOrEmpty(title)
                            title = cleanseString(title)
                            parseForRelevantTerms(title, searchParam)
                        end
                    end

                    allGuests = matchedEpisodes.pluck("guests")
                    allGuests.each do |guests|
                        if !isNilOrEmpty(guests)
                            guestsArr = guests.split(",")
                            guestsArr.each do |guest|
                                guest = cleanseString(guest)
                            end
                            parseForRelevantTerms(guestsArr, searchParam)
                        end
                    end

                    allCars = matchedEpisodes.pluck("cars")
                    allCars.each do |cars|
                        if !isNilOrEmpty(cars)
                            carsArr = cars.split(",")
                            carsArr.each do |car|
                                car = cleanseString(car)
                            end
                            parseForRelevantTerms(carsArr, searchParam)
                        end
                    end

                    #allFeatures = matchedEpisodes.pluck("features")
                    #allFeatures.each do |features|
                    #    if !isNilOrEmpty(features)
                    #        features = cleanseString(features)
                    #        parseForRelevantTerms(features, searchParam)
                    #    end
                    #end
                    
                    allHosts = matchedEpisodes.pluck("hosts")
                    allHosts.each do |hosts|
                        if !isNilOrEmpty(hosts)
                            hostsArr = hosts.split(",")
                            hostsArr.each do |host|
                                host = cleanseString(host)
                            end
                            parseForRelevantTerms(hostsArr, searchParam)
                        end
                    end

                    #allSummaries = matchedEpisodes.pluck("summary")
                    #allSummaries.each do |summary|
                    #    if !isNilOrEmpty(summary)
                    #        summary = cleanseString(summary)
                    #        parseForRelevantTerms(summary, searchParam)
                    #    end
                    #end

                    allMetas = matchedEpisodes.pluck("meta")
                    allMetas.each do |metas|
                        if !isNilOrEmpty(metas)
                            metasArr = metas.split(",")
                            metasArr.each do |meta|
                                meta = cleanseString(meta)
                            end
                            parseForRelevantTerms(metasArr, searchParam)
                        end
                    end
                end

                @results = @results[0,limitParam]
            end

        private
            def isNilOrEmpty(input)
                if !input.nil? && !input.empty?
                    return false
                else
                    return true
                end
            end

            def isNil(input)
                if !input.nil?
                    return false
                else
                    return true
                end
            end

            def stringContainsTermAtWordStart(string, term)
                stringArr = string.split(" ")
                termArr = term.split(" ")

                stringArr.each_with_index do |stringArrItem, index|
                    termFirstWord = termArr[0]
                    stringArrItemSliced = stringArrItem.slice(0..(termFirstWord.length - 1))
                    if normalizeString(stringArrItemSliced) == normalizeString(termFirstWord)
                        return true
                    end
                end
                
                return false
            end

            def normalizeString(input)
                if !isNilOrEmpty(input)
                    return input.downcase
                end
            end

            def cleanseString(input)
                if !isNilOrEmpty(input)
                    return input.gsub("\"","").gsub("[","").gsub("]","").gsub(":","").gsub(";","").gsub("(","").gsub(")","").gsub(".","").strip()
                end
            end

            def prepString(input)
                if !isNilOrEmpty(input)
                    normalizedInput = normalizeString(input)
                    cleansedInput = cleanseString(normalizedInput)
                end
            end
            
            def getStringStartingWithTerm(input, term)
                stringStartingWithTerm = ""

                if !isNilOrEmpty(input) && !isNilOrEmpty(term)
                    termIndex = input.index(term)
                    if !isNil(termIndex)
                        stringStartingWithTerm = input.slice(termIndex..input.length)
                    end
                end

                return stringStartingWithTerm
            end

            def getMatchingStringsForTerm(input, term)
                matches = []

                if !isNilOrEmpty(input)
                    if input.kind_of?(Array)
                        input.each do |item|
                            item = cleanseString(item)
                            if stringContainsTermAtWordStart(item, term)
                                matches << item
                            end
                        end
                    else
                        input = cleanseString(input)
                        if stringContainsTermAtWordStart(input, term)
                            matches << input
                        end
                    end
                end

                return matches
            end

            def parseForRelevantTerms(input, searchTerm)
                searchTermArr = searchTerm.split(" ")

                matches = getMatchingStringsForTerm(input, searchTerm)
                matches.each do |match|
                    match = prepString(match)
                    matchStartingWithTerm = getStringStartingWithTerm(match, searchTerm)
                    if !isNilOrEmpty(matchStartingWithTerm)
                        matchStartingWithTermArr = matchStartingWithTerm.split(" ")
                        fullSuggestion = matchStartingWithTermArr[0]
                        searchTermArr.each_with_index do |term, index|
                            if index > 0
                                fullSuggestion = fullSuggestion + " " + matchStartingWithTermArr[index]
                            end
                        end
                        if normalizeString(fullSuggestion) == normalizeString(searchTerm)
                            nextWord = matchStartingWithTermArr[searchTermArr.length]
                            if !isNilOrEmpty(nextWord)
                                fullSuggestion = fullSuggestion + " " + nextWord
                            end
                        end
                        if !@results.include? fullSuggestion
                            @results << fullSuggestion
                        end
                    end
                end
            end
    end
end
