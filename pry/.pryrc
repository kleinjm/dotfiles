# See https://github.com/pry/pry/issues/1048#issuecomment-30567134
Pry.pager = nil

require_relative "./copy_to_clipboard"

def my_user
  User.find_by(email: "james.klein@asktrim.com")
end

def clear_sidekiq
  Sidekiq.redis(&:flushdb)
end

if defined?(PryNav)
  Pry.commands.alias_command "c", "continue"
  Pry.commands.alias_command "n", "next"
  Pry.commands.alias_command "s", "step"
end
