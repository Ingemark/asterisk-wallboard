# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Initial user - Admin
user = User.new do |u|
  u.email = "admin@example.com"
  u.password = "administrator"
  u.role = "admin"
  u.extension = "000"
end
user.save