#!/usr/bin/env ruby
require 'aws-sdk-s3'
require 'fileutils'

bucket_name = ENV['AWS_BUCKET_NAME']
project_path = ENV['BACKUP_PATH']
database_name = ENV['DB_NAME'] || 'all_databases'

filepath = ARGV[0]
filename = File.basename(filepath)

# verify file exists and file size is > 0 bytes
unless File.exists?(filepath) && File.new(filepath).size > 0
  raise "Database was not backed up"
end


bucket = Aws::S3::Bucket.new(bucket_name)
object = bucket.object("#{project_path}/#{filename}")

progress = Proc.new do |bytes, totals|
  puts bytes.map.with_index { |b, i| "Uploading part #{i+1}: "}.join(' ') + "#{(100.0 * bytes.sum / totals.sum).round(2) }%" 
end
object.upload_file(filepath, { progress_callback: progress})

if object.exists?
  FileUtils.rm(filepath)
else
  raise "S3 Object wasn't created"
end

DAYS = ENV['AWS_KEEP_FOR_DAYS'].to_i || 30
CHECK_TIME = DAYS * 24 * 60 * 60
bucket.objects(prefix: project_path).each do |o|
  o.delete if o.last_modified < (Time.now - CHECK_TIME)
end