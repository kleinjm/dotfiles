def my_account
  Account.find_by(login: "jklein@doximity.com")
end

def my_user
  my_account.user
end

def make_admin
  my_account << Roles.first
end

def make_pleeb
  my_account.roles = []
end
