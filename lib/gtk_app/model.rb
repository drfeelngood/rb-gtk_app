require 'active_model'

module GtkApp
class Model
  include ActiveModel::Validations

  def initialize
    @errors = ActiveModel::Errors.new(self)
  end

end
end