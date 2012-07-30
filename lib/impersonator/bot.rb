require 'yaml'
require 'cinch'
require 'thread'
require 'sqlite3'
require 'digest/sha1'

require 'impersonator/markov'
require 'impersonator/helper'
require 'impersonator/statements'

include BotHelper

$config     = YAML.load_file File.join(File.dirname(__FILE__), 'bot.yml')
$keywords   = eval("/#{$config['keywords'].join("|")}/i")

log_db      = SQLite3::Database.new(File.join(File.dirname(__FILE__), "bot.db"))
$statements = BotStatements.new(log_db)

$semaphore  = Mutex.new
$authorized = []

bot = Cinch::Bot.new do
  configure do |c|
    c.server        = $config['server']
    c.port          = $config['port']
    c.nick          = $config['nick']
    c.channels      = $config['channels']
    if $config['ssl']
      c.ssl.use     = true
      c.ssl.verify  = false
    end
    if $config['password']
      c.password = $config['password']
    end
  end

  # core responder (bot)
  on :message, do |m|
    # log all messages
    log_message(m)

    next if $config['blacklist'].include? m.user.nick

    if should_speak(m)
      # setup our markov for the user/channel in question
      markov = nil
      $markovs ||= {}
      $semaphore.synchronize {
        if m.channel # in a channel
          markov  = $markovs[m.channel] ||= MarkovChain.new(text_for_channel(m.channel.name))
        else
          user    = $personality_override ? $personality_override : m.user
          markov  = $markovs[user] ||= MarkovChain.new(text_for_user(user))
        end
      }
      sentence = ""
      sentence << m.user.nick << ": " if rand($config['weights']['speak_nick']) == 0
      sentence << markov.generate_sentence(m.message)
      m.reply "#{sentence}"
      log_my_message(m.channel ? m.channel.name : nil, sentence)
    end
  end
end
bot_thread = Thread.new do
  bot.start
end

commandbot = Cinch::Bot.new do
  configure do |c|
    c.server        = $config['command']['server']
    c.port          = $config['command']['port']
    c.nick          = $config['command']['nick']
    c.channels      = $config['command']['channels']
    if $config['command']['ssl']
      c.ssl.use     = true
      c.ssl.verify  = false
    end
  end

  # authentication
  on :message, /auth/, do |m|
    if !m.channel # pm only
      pw = Digest::SHA1.hexdigest(m.message.split("auth ").last.strip)
      if pw == $config['command']['password']
        m.reply("authorized!")
        $semaphore.synchronize {
          $authorized << m.user
          $authorized.uniq!
        }
      end
    end
  end

  on :message, /users/, do |m|
    if !m.channel && $authorized.include?(m.user)
      m.reply("authorized users: #{$authorized.join(', ')}")
    end
  end

  # backlog
  on :message, /backlog #[^\s]*. [0-9]*/, do |m|
    if !m.channel && $authorized.include?(m.user)
      channel, lines = m.message.split[1..2]
      messages = []
      rows = $statements.backlog.execute(channel, lines.to_i)
      rows.each do |row|
        messages << "#{row[0]} #{row[1]}: #{row[2]}"
      end
      messages.reverse.each do |message|
        m.reply(message)
      end
    end
  end

  on :message, /backlog [^#^\s]*. [0-9]*/, do |m|
    if !m.channel && $authorized.include?(m.user)
      user, lines = m.message.split[1..2]
      messages = []
      rows = $statements.backlog_pm.execute(user, lines.to_i)
      rows.each do |row|
        messages << "#{row[0]} #{row[1]}: #{row[2]}"
      end
      messages.reverse.each do |message|
        m.reply(message)
      end
    end
  end

  # personality management
  on :message, /personality [^#^\s]*./, do |m|
    if !m.channel && $authorized.include?(m.user)
      $personality_override = m.message.split[1]
      m.reply "personality set to #{$personality_override}"
    end
  end

  on :message, /personality$/, do |m|
    if !m.channel && $authorized.include?(m.user)
      $personality_override = nil
      m.reply "personality override cleared"
    end
  end
end
command_thread = Thread.new do
  commandbot.start
end

bot_thread.join
command_thread.join