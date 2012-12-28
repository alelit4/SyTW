class AddCustom < ActiveRecord::Migration
  def up
    add_column :shortened_urls, :custom, :string
  end

  def down
    remove_column :shortened_urls, :custom
  end
end
