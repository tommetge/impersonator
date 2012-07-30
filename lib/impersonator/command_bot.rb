require 'cinch'
require 'digest/sha2'
require 'impersonator/helper'

class CommandBot
  include Cinch::Plugin

  listen_to :channel

  match /auth (.+)/,                method: :auth
  match /users/,                    method: :users
  match /backlog [^#^\s]*. [0-9]*/, method: :bl_user
  match /backlog #[^\s]*. [0-9]*/,  method: :bl_channel
  # match /personality$/,             method: :reset_personality
  # match /personality [^#^\s]*./,    method: :override_personality

  def initialize(*args)
    super

    @config = @bot.config
    @db = @config.db
    @keywords = eval("/#{@config.keywords.join("|")}/i")
    @passwd = config['command']['password'] ||
               Digest::SHA1.hexdigest("impersonate!")
    @users = []
  end

  def authorized?(m)
    !m.channel && @users.include?(m.user)
  end

  def auth(m, passwd)
    if Digest::SHA1.hexdigest(passwd) == @passd
      m.reply('authorized!')
      unless @users.include?(m.user)
        @users << m.user
      end
    end
  end

  def users(m)
    if authorized?(m)
      m.reply("authorized users: #{@users.join(", ")}")
    end
  end

  def bl_user(m, user, lines)
    if authorized?(m)
      messages = []
      rows = @db.backlog_pm.execute(user, lines.to_i)
      rows.reverse.each do |row|
        m.reply("#{row[0]} #{row[1]}: #{row[2]}")
      end
    end
  end

  def bl_channel(m, channel, lines)
    if authorized?(m)
      messages = []
      rows = @db.backlog_pm.execute(user, lines.to_i)
      rows.reverse.each do |row|
        m.reply("#{row[0]} #{row[1]}: #{row[2]}")
      end
    end
  end

  def reset_personality(m)
    if authorized?(m)
      # FIXME: implement
    end
  end

  def override_personality(m, person)
    if authorized?(m)
      # FIXME: implement
    end
  end
end