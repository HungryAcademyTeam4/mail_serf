class IncomingEmail < ActiveRecord::Base
  attr_accessible :body, :subject
end
