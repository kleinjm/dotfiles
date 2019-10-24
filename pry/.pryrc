# See https://github.com/pry/pry/issues/1048#issuecomment-30567134
Pry.pager = nil

require_relative "./copy_to_clipboard"

def my_account
  Account.find_by(login: "jklein@doximity.com")
end

def my_user
  my_account.user
end

def make_admin
  my_account.roles << Role.first
  # doc news admin
  my_account.roles << Role.find(20)
end

def make_pleeb
  my_account.roles = []
end

def clear_sidekiq
  Sidekiq.redis(&:flushdb)
end

if defined?(PryNav)
  Pry.commands.alias_command "c", "continue"
  Pry.commands.alias_command "n", "next"
  Pry.commands.alias_command "s", "step"
end
