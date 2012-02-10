module GtkApp
module Helpers
  
  def log
    GtkApp.logger
  end

  class Array

    def extract_options!
      last.is_a?(Hash) && last.extractable_options? ? pop : {}
    end

  end
  
end
end