class IncomingEmail < ActiveRecord::Base
  attr_accessible :body, :subject, :sender, :recipient

  def self.receive_email(message)
    subject = message.subject 
    unless !subject.present? 
      ie = IncomingEmail.new(subject:message.subject,
                        recipient:message.to.decoded, 
                        body:message.body.decoded, 
                        sender:message.from.first)
      ie.save
    end
  end
end
