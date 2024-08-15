class UpdateArmiesTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :armies, :col0, :integer
    remove_column :armies, :col1, :integer
    remove_column :armies, :col2, :integer
    remove_column :armies, :col3, :integer
    remove_column :armies, :col4, :integer
    remove_column :armies, :col5, :integer
    remove_column :armies, :col6, :integer
    remove_column :armies, :col7, :integer
    remove_column :armies, :col8, :integer
    remove_column :armies, :col9, :integer

    add_column :armies, :men1, :integer, default: 0
    add_column :armies, :men2, :integer, default: 0
    add_column :armies, :men3, :integer, default: 0
    add_column :armies, :men4, :integer, default: 0
    add_column :armies, :men5, :integer, default: 0
    add_column :armies, :men6, :integer, default: 0
    add_column :armies, :men7, :integer, default: 0
    add_column :armies, :men8, :integer, default: 0
    add_column :armies, :men9, :integer, default: 0

    add_column :armies, :attr0, :integer, default: 0
    add_column :armies, :attr1, :integer, default: 0
    add_column :armies, :attr2, :integer, default: 0
    add_column :armies, :attr3, :integer, default: 0
    add_column :armies, :attr4, :integer, default: 0
    add_column :armies, :attr5, :integer, default: 0
    add_column :armies, :attr6, :integer, default: 0
    add_column :armies, :attr7, :integer, default: 0
    add_column :armies, :attr8, :integer, default: 0
    add_column :armies, :attr9, :integer, default: 0

    add_column :armies, :army_type, :string, default: "conscript"
  end
end
