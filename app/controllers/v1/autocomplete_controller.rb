module V1
    class AutocompleteController < ApplicationController
        public
            def index
                if params[:search]
                    @results = []

                    searchParam = params[:search].downcase

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
                            parseForRelevantNextWords(title, searchParam)
                        end
                    end

                    allGuests = matchedEpisodes.pluck("guests")
                    allGuests.each do |guests|
                        if !isNilOrEmpty(guests)
                            guestsArr = guests.split(",")
                            guestsArr.each do |guest|
                                guest = cleanseString(guest)
                            end
                            parseForRelevantNextWords(guestsArr, searchParam)
                        end
                    end

                    allCars = matchedEpisodes.pluck("cars")
                    allCars.each do |cars|
                        if !isNilOrEmpty(cars)
                            carsArr = cars.split(",")
                            carsArr.each do |car|
                                car = cleanseString(car)
                            end
                            parseForRelevantNextWords(carsArr, searchParam)
                        end
                    end

                    #allFeatures = matchedEpisodes.pluck("features")
                    #allFeatures.each do |features|
                    #    if !isNilOrEmpty(features)
                    #        features = cleanseString(features)
                    #        parseForRelevantNextWords(features, searchParam)
                    #    end
                    #end
                    
                    allHosts = matchedEpisodes.pluck("hosts")
                    allHosts.each do |hosts|
                        if !isNilOrEmpty(hosts)
                            hostsArr = hosts.split(",")
                            hostsArr.each do |host|
                                host = cleanseString(host)
                            end
                            parseForRelevantNextWords(hostsArr, searchParam)
                        end
                    end

                    #allSummaries = matchedEpisodes.pluck("summary")
                    #allSummaries.each do |summary|
                    #    if !isNilOrEmpty(summary)
                    #        summary = cleanseString(summary)
                    #        parseForRelevantNextWords(summary, searchParam)
                    #    end
                    #end

                    allMetas = matchedEpisodes.pluck("meta")
                    allMetas.each do |metas|
                        if !isNilOrEmpty(metas)
                            metasArr = metas.split(",")
                            metasArr.each do |meta|
                                meta = cleanseString(meta)
                            end
                            parseForRelevantNextWords(metasArr, searchParam)
                        end
                    end
                end
            end

        private
            def isNilOrEmpty(input)
                if !input.nil? && !input.empty?
                    return false
                else
                    return true
                end
            end

            def stringContainsTerm(string, term)
                return string.downcase.include? term.downcase
            end

            def stringContainsTermAtStart(string, term)
                string = string.downcase
                term = term.downcase
                match = string.slice(0..(term.length - 1))
                if match == term
                    return true
                else
                    return false
                end
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
            
            def getInputWithTerm(input, term)
                if !isNilOrEmpty(input) && !isNilOrEmpty(term)
                    termIndex = input.index(term)
                    inputWithTerm = input.slice(termIndex..input.length)
                    return inputWithTerm
                end
            end

            def getMatches(input, term)
                matches = []

                if !isNilOrEmpty(input)
                    if input.kind_of?(Array)
                        input.each do |item|
                            item = cleanseString(item)
                            if stringContainsTermAtStart(item, term)
                                matches << item
                            end
                        end
                    else
                        input = cleanseString(input)
                        if stringContainsTermAtStart(input, term)
                            matches << input
                        end
                    end
                end

                return matches
            end

            def parseForRelevantNextWords(input, searchTerm)
                matches = getMatches(input, searchTerm)
                matches.each do |match|
                    preppedMatch = prepString(match)
                    matchWithSearchParam = getInputWithTerm(preppedMatch, searchTerm)
                    if !isNilOrEmpty(matchWithSearchParam)
                        currentTermArr = searchTerm.split(" ")
                        matchWithSearchParamArr = matchWithSearchParam.split(" ")
                        currMatchTerm = matchWithSearchParamArr[0]
                        currentTermArr.each_with_index do |currentTerm, index|
                            if index > 0
                                currMatchTerm = currMatchTerm + " " + matchWithSearchParamArr[index]
                            end
                        end
                        fullSuggestion = currMatchTerm
                        if normalizeString(currMatchTerm) == normalizeString(searchTerm)
                            nextWord = matchWithSearchParam.split(" ")[currentTermArr.length]
                            if !isNilOrEmpty(nextWord)
                                fullSuggestion = fullSuggestion + " " + nextWord
                            end
                        end
                        if fullSuggestion != searchTerm
                            if !@results.include? fullSuggestion
                                @results << fullSuggestion
                            end
                        end
                    end
                end
            end
    end
end
