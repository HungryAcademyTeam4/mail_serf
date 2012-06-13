class IncomingEmail < ActiveRecord::Base
  attr_accessible :body, :subject, :sender, :recipient, :chatroom_id

  def self.receive_email(message)
    subject = message.subject 
    unless !subject.present? 
      ie = IncomingEmail.create(subject:message.subject,
                             recipient:message.to, 
                             body:message.body.decoded, 
                             sender:message.from.first,
                             chatroom_id:get_chatroom_id(message.to))
      Message.create(content:ie, user_id:"email", user:"email", chatroom_id:"")
    end
  end

  def self.get_chatroom_id(addresses)
    addresses.to_s.scan(/\+(\d+)/).first.first
  end 
end

