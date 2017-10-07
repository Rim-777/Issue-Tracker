module Tracker
  %i[
    InvalidEventError
  ].each { |exception| self.const_set(exception, Class.new(StandardError)) }
end