# frozen_string_literal: true

BACKUP_PATH = '/app/minecraft/server-data/backup'

last_time = nil
running = true
instant_mode = ARGV.include?('-i')

def puts_timestamp(message)
  puts "[Backup daemon][#{Time.now.strftime('%H:%M:%S')}]: #{message}"
end

def initiate_backup
  filename = Time.now.strftime('%Y%m%dT%H%M%S.7z')
  puts_timestamp("begin to backup to #{filename}")
  system "7z a -t7z -m0=lzma2 -mx=3 \"#{BACKUP_PATH}/#{filename}\" \"/app/minecraft/server-data/world\""
end

if instant_mode
  puts_timestamp('Instant backup')
  initiate_backup
  exit 0
end

while running
  if last_time.nil?
    sleep(1_800_000_000)
  else
    puts_timestamp('Scheduled Backup')
    initiate_backup
    current_time = Time.now
    sleep(1_800_000_000 - (current_time.usec - last_time.usec))
  end

  last_time = Time.now
end
