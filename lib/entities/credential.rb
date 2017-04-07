module Intrigue
module Entity
class Credential < Intrigue::Model::Entity

  def self.metadata
    {
      :name => "Credential",
      :description => "Login credential"
    }
  end

  def validate_entity
    name =~ /^\w.*/ &&
    details["username"].to_s =~ /^\w.*$/ &&
    details["password"].to_s =~ /^\w.*$/ &&
    details["uri"].to_s =~ /^\w.*$/
  end

end
end
end
