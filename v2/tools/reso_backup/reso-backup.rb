require 'rubygems'
require 'bundler/setup'

require 'date'
require 'aws/s3'
require 'pony'

require_relative 'settings'

module ResoBackup
  def self.run
    message = ""
    success = false
    backup_file = ""
    file_name = ""
    begin
      $RESO_BACKUP_ROOT = File.expand_path(File.dirname(__FILE__))

      #stamp the filename
      datestamp = Time.now.strftime("%Y%m%d-%H%M%S")

      #drop it in the db/backups directory temporarily
      file_name = "resonance_#{datestamp}_dump.sql.gz"
      backup_file = "#{$RESO_BACKUP_ROOT}/db/#{file_name}"

      #dump the backup and zip it up
      `pg_dump -h #{Settings.db.host} -U #{Settings.db.username} #{Settings.db.name} | gzip -c > #{backup_file}`

      upload_to_s3 backup_file

      remove_old_backups(10)

      message = "Another successful backup"
      success = true
    rescue Exception => e
      message = e.message
      success = false
    ensure
      result = success ? "SUCCESS" : "FAILED"
      Pony.mail({
        :to => Settings.mailer.to,
        :from => Settings.mailer.from,
        :subject => "ResoBackup (#{result})",
        :body => message,
        :attachments => {
          file_name => File.read(backup_file)
        },
        :via => :smtp,
        :via_options => {
          :address              => Settings.mailer.address,
          :port                 => Settings.mailer.port,
          :enable_starttls_auto => Settings.mailer.enable_starttls_auto,
          :user_name            => Settings.mailer.user_name,
          :password             => Settings.mailer.password,
          :authentication       => Settings.mailer.authentication,
          :domain               => Settings.mailer.domain
        }
      })
      File.delete backup_file
    end
  end

  private

  def self.remove_old_backups(num_to_keep)
    AWS::S3::Base.establish_connection!(:access_key_id => Settings.S3.public_key, :secret_access_key => Settings.S3.private_key)
    reso_bucket = AWS::S3::Bucket.find(Settings.S3.bucket)
    backups = reso_bucket.objects(:prefix => 'db_backups/resonance')
    if backups.count > num_to_keep
      bu = []
      backups.each do |b|
        last_modified = b.about["last-modified"].nil? ? nil : b.about["last-modified"]
        if last_modified and b.key.include? 'dump.sql.gz'
          time = DateTime.parse(last_modified)
          bu << { :time => time, :backup => b }
        end
      end
      bu = bu.sort_by { |b| b[:time] }
      to_be_removed = bu.slice(0, (bu.count - num_to_keep).abs)
      to_be_removed.each do |r|
        r[:backup].delete
      end
    end
  end

  def self.upload_to_s3(file_path)
    bucket = Settings.S3.bucket
    file_name = "db_backups/#{File.basename(file_path)}"
    AWS::S3::Base.establish_connection!(:access_key_id => Settings.S3.public_key, :secret_access_key => Settings.S3.private_key)
    AWS::S3::S3Object.store(file_name, File.open(file_path), bucket)
  end
end

ResoBackup.output_bucket_files