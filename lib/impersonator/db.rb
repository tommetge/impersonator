require 'sqlite3'

class ImpersonatorDB
  attr_reader :log_message, :log_my_message, :backlog, :backlog_pm
  def initialize(path)
    @path = path
    @db = SQLite3::Database.new(@path)

    # schema
    sql = <<SQL
      CREATE TABLE IF NOT EXISTS messages 
        (time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        channel CHAR(255) DEFAULT NULL,
        nick CHAR(255) NOT NULL,
        message TEXT,
        mention BOOLEAN DEFAULT FALSE);
      CREATE INDEX IF NOT EXISTS messages_channel_idx ON messages (channel);
      CREATE INDEX IF NOT EXISTS messages_nick_idx ON messages (nick);
      CREATE INDEX IF NOT EXISTS messages_time_idx ON messages (time);
      CREATE INDEX IF NOT EXISTS messages_mention_idx ON messages (mention);
SQL
    @db.execute(sql)

    # prepared statements
    sql = <<SQL
      INSERT INTO messages
        (channel, nick, message, mention)
        VALUES (?, ?, ?, ?)
SQL
    @log_message = @db.prepare(sql)
    sql = <<SQL
      INSERT INTO messages
        (channel, nick, message)
        VALUES (?, ?, ?)
SQL
    @log_my_message = @db.prepare(sql)
    sql = <<SQL
      SELECT time, nick, message
        FROM messages
        WHERE channel = ?
        ORDER BY time
        DESC LIMIT ?
SQL
    @backlog = @db.prepare(sql)
    sql = <<SQL
      SELECT time, nick, message
        FROM messages
        WHERE nick = ?
        AND CHANNEL IS NULL
        ORDER BY time
        DESC LIMIT ?
SQL
    @backlog_pm = @db.prepare(sql)
  end
end