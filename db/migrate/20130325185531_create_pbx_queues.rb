class CreatePbxQueues < ActiveRecord::Migration
  def change
    create_table :pbx_queues do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
