json.ignore_nil!

json.series_number          @episode['episode_json']['series_number']
json.episode_number         @episode['episode_json']['episode_number']
json.title                  @episode['episode_json']['title']
json.air_date               @episode['episode_json']['air_date']
json.guests do
    json.array! @episode['episode_json']['guests'] do |guest|
        json.name               guest['name']
    end
end
json.hosts do
    json.array! @episode['episode_json']['hosts'] do |host|
        json.name               host['name']
    end
end
json.cars do
    json.array! @episode['episode_json']['cars'] do |car|
        json.name               car['name']
    end
end
json.features do
    json.array! @episode['episode_json']['features'] do |feature|
        json.description        feature['description']
    end
end