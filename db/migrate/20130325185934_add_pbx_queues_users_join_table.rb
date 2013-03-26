class AddPbxQueuesUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :pbx_queues_users, :id => false do |t|
      t.integer :pbx_queue_id
      t.integer :user_id
    end
  end
end
