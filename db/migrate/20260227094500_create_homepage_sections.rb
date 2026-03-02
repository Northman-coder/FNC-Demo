class CreateHomepageSections < ActiveRecord::Migration[7.0]
  def change
    create_table :homepage_sections do |t|
      t.string :identifier, null: false, index: { unique: true }
      t.string :label
      t.string :headline
      t.text   :description
      t.string :link_text
      t.string :link_url

      t.timestamps
    end
  end
end
