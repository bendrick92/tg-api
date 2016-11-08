# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

module V1
    series_1_seed = Rails.root.join('db', 'seeds', 'series_1.yml')
    series_23_seed = Rails.root.join('db', 'seeds', 'series_23.yml')

    data = YAML::load_file(series_1_seed)
    data += YAML::load_file(series_23_seed)
    
    Episode.create!(data)
end