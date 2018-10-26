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

if defined?(Pry)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 's', 'step'
end

def _cp(obj = Readline::HISTORY.entries[-2], *options)
  if obj.respond_to?(:join) && !options.include?(:a)
    if options.include?(:s)
      obj = obj.map { |element| ":#{element.to_s}" }
    end
    out = obj.join(", ")
  elsif obj.respond_to?(:inspect)
    out = obj.is_a?(String) ? obj : obj.inspect
  end

  if out
    IO.popen('pbcopy', 'w') { |io| io.write(out) }
    "copied!"
  end
end

def _cp_help
  puts <<-HELP

_cp - copy stuff to OS X clipboard

If no argument is given it takes the last line in HISTORY:
  >> 5.times { "nothing"  }
  # => 5
  >> _cp
  # => "copied!"
  Pasteboard: 5.times { "nothing"  }

Copy the result of the given argument:
  >> _cp %w[foo bar]
  # => "copied!"
  Pasteboard: foo, bar

Convert array elements to symbols:
  >> _cp %w[foo bar], :s
  # => "copied!"
  Pasteboard: :foo, :bar

Copy an array as syntax:
  >> _cp %w[foo bar], :a
  # => "copied!"
  Pasteboard: ["foo", "bar"]

Copy a hash:
  >> h = { foo: 'bar', 'foo' => :bar }
  # => {:foo=>"bar", "foo"=>:bar}
  # >> _cp h
  # => "copied!"
  Pasteboard: {:foo=>"bar", "foo"=>:bar}

  HELP
end
