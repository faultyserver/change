require "./src/change"
require "pg"

class User
  include Change
  include Change::SQL

  source :users

  field name : String
  field age : Int32
  field bio : String

  {% begin %}
    DB.mapping({
      {{*FIELDS.map{ |f| "#{f[:name]}: #{f[:type]}?".id } }}
    })
  {% end %}

  def initialize; end

  def self.changeset(instance, changes={} of String => String)
    Changeset.new(instance)
      .cast(changes, [:name, :age, :bio])
      .validate_required([:name, :age])
  end
end


conn = DB.open("a database url")
pp Change::Repo.all(conn, User)


changeset = User.changeset(User.new, {name: "John", age: 23})

puts Change::Repo.insert(conn, changeset)
