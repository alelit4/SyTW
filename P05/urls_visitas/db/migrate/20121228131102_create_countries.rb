class CreateCountries < ActiveRecord::Migration
    def up
        create_table :countries do |t| 
            t.string :url
            t.string :country
            t.integer :count, :default => 0
        end
        add_index :countries, :url
    end

    def down
        drop_table :countries
    end
end
