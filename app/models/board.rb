# == Schema Information
#
# Table name: boards
#
#  id          :integer(4)      not null, primary key
#  login       :string(255)
#  user_agent  :string(255)
#  user_id     :integer(4)
#  object_id   :integer(4)
#  object_type :string(255)
#  message     :text
#  created_at  :datetime
#

# It's the famous board, from DaCode (then templeet).
#
class Board < ActiveRecord::Base
  belongs_to :user
  belongs_to :object, :polymorphic => true

  default_scope :order => 'created_at DESC'
  named_scope :by_type, lambda { |type|
    { :include => [:user], :conditions => { :object_type => type } }
  }

### Types ###

  # There are several boards:
  #  * the free one for testing
  #  * the writing board is used for collaborating the future news
  #  * the AMR board is used by the LinuxFR.org staff
  #  * and one board for each news in moderation.
  TYPES = %w(Free Writing AMR News)

  TYPES.each do |type|
    self.class.send(:define_method, type.downcase) { type }
  end

  def self.[](type)
    raise ActiveRecord::RecordNotFound unless TYPES.include?(type)
    board = Board.new
    board.object_type = type
    board
  end

### Validation ###

  validates_presence_of :object_type
  validates_presence_of :object_id
  validates_presence_of :login
  validates_presence_of :user_agent
  validates_presence_of :message

  validates_inclusion_of :object_type, :in => TYPES

### ACL ###

  # Can the given user see messages (and post) on this board?
  def accessible_by?(user)
    return false unless user
    case object_type
    when Board.news:    user.amr?
    when Board.amr:     user.amr?
    when Board.writing: user.can_post_on_board?
    when Board.free:    user.can_post_on_board?
    else                false
    end
  end

end
