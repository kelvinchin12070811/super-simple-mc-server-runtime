# frozen_string_literal: true

require_relative './rcon'

BACKUP_PATH = '/app/minecraft/server-data/backup'
BACKUP_ENABLED = ENV['ENABLE_BACKUP'] == 'TRUE'
BACKUP_DURATION = lambda do
  duration = ENV['BACKUP_DURATION'].to_i
  duration <= 0 ? 30 : duration
end.call * 60 * 1000

last_time = nil
running = true
instant_mode = ARGV.include?('-i')

puts BACKUP_DURATION.class

def puts_timestamp(message)
  puts "[Backup daemon][#{Time.now.strftime('%H:%M:%S')}]: #{message}"
end

def initiate_backup
  return unless BACKUP_ENABLED == true

  rcon('say §9Starting backup, server might be a little bit laggy!')
  filename = Time.now.strftime('%Y%m%dT%H%M%S.7z')
  puts_timestamp("begin to backup to #{filename}")
  rcon('save-off')
  rcon('save-all')
  system "7z a -t7z -m0=lzma2 -mx=3 \"#{BACKUP_PATH}/#{filename}\" \"/app/minecraft/server-data/world\""
  rcon('save-on')

  system "find '#{BACKUP_PATH}' -type f -mtime +2 -name '*.7z' -delete"
  rcon('say §2Backup finished!')
end

if instant_mode
  puts_timestamp('Instant backup')
  initiate_backup
  exit 0
end

puts_timestamp('Backup daemon started')
puts_timestamp("Backup enabled: #{BACKUP_ENABLED}")
puts_timestamp("Backup duration: #{BACKUP_DURATION} milliseconds")

while running
  puts_timestamp('Checking backups')
  if last_time.nil?
    sleep(BACKUP_DURATION)
  else
    rcon('say §6Scheduled backup will begin in 5 minutes. The server may experience brief lag during this time!')
    sleep(300_000)
    initiate_backup
    current_time = Time.now
    sleep((BACKUP_DURATION - 300_000) - (current_time.usec - last_time.usec))
  end

  last_time = Time.now
end
