class CreateLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :logs do |t|
      t.text :search_term, null: false, default: ""
      t.datetime :search_time, null: false, default: DateTime.now

      t.timestamps
    end
  end
end
