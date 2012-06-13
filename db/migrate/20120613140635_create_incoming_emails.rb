class CreateIncomingEmails < ActiveRecord::Migration
  def change
    create_table :incoming_emails do |t|
      t.string :subject
      t.string :sender
      t.string :recipient
      t.integer :chatroom_id
      t.text :body

      t.timestamps
    end
  end
end
