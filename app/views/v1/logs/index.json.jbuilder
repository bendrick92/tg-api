json.ignore_nil!

json.array! @logs.each do |log|
    json.search_term            log.search_term
    json.search_time            log.search_time
end