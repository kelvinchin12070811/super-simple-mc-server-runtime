# frozen_string_literal: true

require_relative './rcon'

BACKUP_PATH = '/app/minecraft/server-data/backup'
ENABLE_BACKUP = lambda do
  result = ENV['ENABLE_BACKUP'].downcase
  result == 'true'
end.call

unless ENABLE_BACKUP
  puts 'Back up not enabled, set the environment variable\"ENABLE_BACKUP\" to \"TRUE\" to enable it!'
  exit 0
end

instant_mode = ARGV.include?('-i')
annouce_backup = ARGV.include?('-a')
start_backup = ARGV.include?('-b')

def puts_timestamp(message)
  puts "[Backup daemon][#{Time.now.strftime('%H:%M:%S')}]: #{message}"
end

def initiate_backup(instant_mode: false)
  return unless Dir.exist?('/app/minecraft/server-data/world')

  rcon('say §9Starting backup, the server may experience brief lag!') unless instant_mode
  filename = Time.now.strftime('%Y%m%dT%H%M%S.7z')
  puts_timestamp("begin to backup to #{filename}")
  rcon('save-off')
  rcon('save-all')
  system "7z a -t7z -m0=lzma2 -mx=3 \"#{BACKUP_PATH}/#{filename}\" \"/app/minecraft/server-data/world\""
  rcon('save-on')

  system "find '#{BACKUP_PATH}' -type f -mtime +2 -name '*.7z' -delete"
  rcon('say §2Backup finished!') unless instant_mode
end

if instant_mode
  puts_timestamp('Instant backup')
  initiate_backup(instant_mode: true)
end

if annouce_backup
  rcon('say §6Scheduled backup will begin in 5 minutes. The server may experience brief lag during this time!')
end

initiate_backup if start_backup && File.exist?('/app/minecraft/server-data/server.pid')
