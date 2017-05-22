def my_account
  Account.find_by(login: "jklein@doximity.com")
end

def my_user
  my_account.user
end
