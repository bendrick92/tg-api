json.ignore_nil!

json.array! @episodes.each do |episode|
    json.series_number          episode['episode_json']['series_number']
    json.episode_number         episode['episode_json']['episode_number']
    json.title                  episode['episode_json']['title']
    json.air_date               episode['episode_json']['air_date']
    json.guests                 episode['episode_json']['guests']
    json.hosts                  episode['episode_json']['hosts']
    json.cars                   episode['episode_json']['cars']
    json.features               episode['episode_json']['features']
    json.summary                episode['episode_json']['summary']
end