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
      Message.create(:message =>
                       {content: "Email: #{ie.subject.to_s} from #{ie.sender.to_s}",
                        chat_room_id: get_chatroom_id(message.to),
                        token: 'ruby_jobs'})
    end
  end

  def self.get_chatroom_id(addresses)
    addresses.to_s.scan(/\+(\d+)/).first.first
  end
end

