module BotHelper
  def text_for_user(username)
    puts "Using personality: #{username}"
    statements = `grep " > tom:" #{@config.logs}/*/#{username}* | awk '{ split($0,a," > tom: "); print a[2]}'`
    puts "statements: #{statements}"
    return statements
  end

  def text_for_channel(channel)
    statements = `grep " > tom:" #{@config.logs}/irc/*/#{channel}* | awk '{ split($0,a," > tom: "); print a[2]}'`
  end

  def speak_channel
    if @config.weights && @config.weights.channel
      return rand(@config.weights.channel) == 0
    end
    return rand(3) == 0
  end

  def speak_message
    if @config.weights && @config.weights.message
      return rand(@config.weights.message) == 0
    end
    return rand(1) == 0
  end

  def should_speak_nick
    if @config.weights && @config.weights.speak_nick
      if rand(@config.weights.speak_nick) == 0
        return true
      end
    end
    false
  end

  def should_speak(message)
    return true if message.message.include? 'tom'
    speak = false
    if message.channel
      speak = speak_channel
    else
      return true if message.message.include? '?' # always answer questions
      speak = speak_message
    end
    puts "speak? #{speak}"
    speak
  end

  def log_message(m)
    return unless @config.logging_enabled
    mentioned = (m.message =~ @keywords) ? 1 : 0
    @db.log_message.execute(m.channel ? m.channel.name : nil, m.user.nick, m.message, mentioned)
  end

  def log_my_message(channel, message)
    return unless @config.logging_enabled
    @db.log_my_message.execute(channel, @config.nick, message)
  end
end