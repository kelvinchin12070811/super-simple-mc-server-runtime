# frozen_string_literal: true

require 'json'
require 'fileutils'

release_catelogue = JSON.parse(`curl https://api.github.com/repos/Tiiffi/mcrcon/releases/latest`)
target = release_catelogue['assets'].select do |asset|
  asset['browser_download_url'].end_with?('x86-64.tar.gz')
end
target_url = target[0]['browser_download_url']
target_name = target[0]['name']
target_filename = File.basename(target_name, '.tar.gz')


`curl -OL #{target_url}`
`7z x #{target_filename}.tar.gz`
`7z x #{target_filename}.tar`

Dir.mkdir('bin') unless Dir.exist?('bin')
FileUtils.mv('mcrcon', './bin/mcrcon')
`chmod 755 ./bin/mcrcon`
FileUtils.chmod(755, './bin/mcrcon')

[target_name, "#{target_filename}.tar", 'LICENSE'].each do |file|
  FileUtils.rm(file)
end
