Factory.define :account do |f|
  f.login "ptramo"
  f.role  "moule"
  f.email "ptramo@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
  f.after_create do |a|
    a.password = a.password_confirmation = 'I<3J2EE'
    a.save
  end
end

Factory.define :anonymous_account, :class => 'account' do |f|
  f.login "anonyme"
  f.role  "inactive"
  f.email "anonyme@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :writer_account, :class => 'account' do |f|
  f.login "LionelAllorge"
  f.role  "writer"
  f.email "writer@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :reviewer_account, :class => 'account' do |f|
  f.login "jarillon"
  f.role  "reviewer"
  f.email "reviewer@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :moderator_account, :class => 'account' do |f|
  f.login "floxy"
  f.role  "moderator"
  f.email "moderator@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :admin_account, :class => 'account' do |f|
  f.login "oumph"
  f.role  "admin"
  f.email "admin@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end
