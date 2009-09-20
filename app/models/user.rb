# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  name                :string(100)
#  homesite            :string(255)
#  jabber_id           :string(255)
#  role                :string(255)     default("moule"), not null
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer(4)
#  avatar_updated_at   :datetime
#  created_at          :datetime
#  updated_at          :datetime
#


# The users are the core of LinuxFr.org, its value.
# They can submit contents, vote for them, comment them...
#
# There are several levels of users:
#   * anonymous     -> they have no account and can only read public contents
#   * authenticated -> they can read public contents and submit new ones
#   * reviewer      -> they can review the news while they are in moderation
#   * moderator     -> they makes the order and the security ruling
#   * admin         -> the almighty users
#
class User < ActiveRecord::Base
  include AASM

  has_one  :account, :dependent => :destroy
  has_many :nodes
  has_many :diaries, :dependent => :destroy, :foreign_key => 'owner_id'
  has_many :comments
  has_many :readings, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :relevances, :dependent => :destroy
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true
  
  delegate :login, :email, :to => :account

### SEO ###

  has_friendly_id :login, :use_slug => true

### Sphinx ####

  define_index do
    indexes name, homesite, jabber_id
    where "role != 'inactive'"
    set_property :field_weights => { :name => 5, :homesite => 1, :jabber_id => 1 }
    set_property :delta => :datetime, :threshold => 1.hour
  end

### Avatar ###

  has_attached_file :avatar, :styles      => { :thumbnail => "100x100>" },
                             :path        => ':rails_root/public/uploads/:id_partition/avatar_:style.:extension',
                             :url         => '/uploads/:id_partition/avatar_:style.:extension',
                             :default_url => ':gravatar_url'

  DEFAULT_AVATAR_URL = "http://#{MY_DOMAIN}/images/default_avatar.png"

  Paperclip::Attachment.interpolations[:gravatar_url] = proc do |attachment, style|
    attachment.instance.gravatar_url
  end

  def gravatar_url
    hash = Digest::MD5.hexdigest(account.email.downcase.strip)[0..31]
    "http://www.gravatar.com/avatar/#{hash}.jpg?size=100&d=#{CGI::escape DEFAULT_AVATAR_URL}"
  end

### Role ###

  named_scope :amr, :conditions => {:role => %w[admin moderator reviewer]}

  aasm_column :role
  aasm_initial_state :moule

  aasm_state :inactive
  aasm_state :moule
  aasm_state :writer
  aasm_state :reviewer
  aasm_state :moderator
  aasm_state :admin

  aasm_event :inactivate            do transitions :from => [:moule, :writer, :reviewer, :moderator, :admin], :to => [:inactive] end
  aasm_event :reactivate            do transitions :from => [:inactive],                   :to => [:moule]     end
  aasm_event :give_writer_rights    do transitions :from => [:moule, :reviewer],           :to => [:writer]    end
  aasm_event :give_reviewer_rights  do transitions :from => [:moule, :writer, :moderator], :to => [:reviewer]  end
  aasm_event :give_moderator_rights do transitions :from => [:reviewer, :admin],           :to => [:moderator] end
  aasm_event :give_admin_rights     do transitions :from => [:moderator],                  :to => [:admin]     end

  # An AMR is someone who is either an admin, a moderator or a reviewer
  def amr?
    admin? || moderator? || reviewer?
  end

  def active?
    role != 'inactive'
  end

### Actions ###

  def can_post_on_board?
    active?
  end

  def tag(node, tags)
    node.set_taglist(tags, self)
  end

  def read(node)
    Reading.update_for(node.id, self.id)
  end

end
