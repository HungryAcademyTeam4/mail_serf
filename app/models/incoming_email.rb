class IncomingEmail < ActiveRecord::Base
  attr_accessible :body, :subject, :sender, :recipient, :chatroom_id
  #:chatroom_id

  def self.receive_email(message)
    subject = message.subject 
    unless !subject.present? 
      ie = IncomingEmail.new(subject:message.subject,
                             recipient:message.to, 
                             body:message.body.decoded, 
                             sender:message.from.first,
                             chatroom_id:get_chatroom_id(message.to))
      ie.save
    end
  end

  def get_chatroom_id(*message)
    chatroom_id = message.match(/[\d{1,10}]/).to_s
  end 
end
