require 'cinch'
require 'digest/sha2'
require 'impersonator/helper'

class ImpersonatorBot
  include Cinch::Plugin
  include BotHelper

  listen_to :channel, method: :on_channel_msg
  listen_to :message, method: :on_priv_msg

  def initialize(*args)
    super

    @config   = @bot.config
    @db       = @config.db
    @markovs  = {}

    if @config.keywords
      @keywords = eval("/#{@config.keywords.join("|")}/i")
    end
  end

  def on_channel_msg(m)
    log_message(m)
    
    # FIXME: re-enable blacklisting
    # next if $config['blacklist'].include? m.user.nick

    if should_speak(m)
      # setup our markov for the user/channel in question
      channel_text = text_for_channel(m.channel.name)
      markov = @markovs[m.channel] ||= MarkovChain.new(channel_text)
      sentence = ""
      if should_speak_nick
        sentence << m.user.nick << ": "
      end
      sentence << markov.generate_sentence(m.message)
      m.reply sentence

      log_my_message(m.channel.name, sentence)
    end
  end

  def on_priv_msg(m)
    log_message(m)

    # respect a user's blacklist, if provided
    return if @config.blacklist && @config.blacklist.include?(m.user.nick)

    if should_speak(m)
      # setup our markov for the user/channel in question
      # text = text_for_user(m.user.name)
      text = text_for_user('jeremy')
      markov = @markovs[m.user] ||= MarkovChain.new(text)
      sentence = ""
      if should_speak_nick
        sentence << m.user.nick << ": "
      end
      sentence << markov.generate_sentence(m.message)
      m.reply sentence

      log_my_message(m.user.name, sentence)
    end
  end
end
