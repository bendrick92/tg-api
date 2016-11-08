class CreateEpisodes < ActiveRecord::Migration[5.0]
  def change
    create_table :episodes do |t|
      t.jsonb :episode_json, null: false, default: {}

      t.timestamps
    end
  end
end
