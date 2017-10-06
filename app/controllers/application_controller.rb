require "application_responder"

class ApplicationController < ActionController::API
  self.responder = ApplicationResponder
end
