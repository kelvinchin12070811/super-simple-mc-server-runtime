# frozen_string_literal: true

BACKUP_PATH = '/app/minecraft/server-data/backup'

last_time = nil
running = true

def puts_timestamp(message)
  puts "[Backup daemon][#{Time.now.strftime('%H:%M:%S')}]: #{message}"
end

def initiate_backup
  filename = Time.now.strftime('%Y%m%dT%H%M%S.7z')
  puts_timestamp("begin to backup to #{filename}")
  system "7z a -t7z -m0=lzma2 -mx=3 \"#{BACKUP_PATH}/#{filename}\" \"/app/minecraft/server-data/world\""
end

at_exit do
  puts_timestamp('Last backup before stop')
  initiate_backup
  running = false
end

last_time = Time.now if last_time.nil?

while running
  initiate_backup
  current_time = Time.now
  sleep(1_800_000_000 - (current_time.usec - last_time.usec))
  last_time = Time.now
end
