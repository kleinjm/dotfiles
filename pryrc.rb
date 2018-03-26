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

def set_old_article
  AbTest.for_user(my_user).find_by(name: '2017-12-07_Article_Redesign').
    update_attributes(choice: "old")
end

def set_new_article
  AbTest.for_user(my_user).find_by(name: '2017-12-07_Article_Redesign').
    update_attributes(choice: "new")
end

def clear_sidekiq
  Sidekiq.redis { |conn| conn.flushdb  }
end
