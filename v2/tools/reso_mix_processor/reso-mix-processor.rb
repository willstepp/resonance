require 'rubygems'
require 'bundler/setup'
require 'fileutils'

require 'date'
require 'aws/s3'
require 'pony'
require 'pg'

require_relative 'settings'

module ResoMixProcessor
  UNPROCESSED = 0
  PROCESSED = 1

  def self.run
    $RESO_MIX_PROCESSOR_ROOT = File.expand_path(File.dirname(__FILE__))

    AWS::S3::Base.establish_connection!(:access_key_id => Settings.S3.public_key, 
                                        :secret_access_key => Settings.S3.private_key)
    reso_bucket = AWS::S3::Bucket.find(Settings.S3.bucket)

    output = "Mixes Processed:\n"

    conn = PGconn.open(Settings.db.host, 
                       Settings.db.port, '', '', 
                       Settings.db.name, 
                       Settings.db.username, 
                       Settings.db.password)
    mixes = conn.exec("select * from mixes where state = #{UNPROCESSED}")
    if mixes.count > 0
      mixes.each do |mix|
        uuid = mix['uuid']

        mix_zip_file = "#{$RESO_MIX_PROCESSOR_ROOT}/mixes/#{uuid}.zip"
        mix_tmp_dir = "#{$RESO_MIX_PROCESSOR_ROOT}/mixes/#{uuid}"
        mix_wav_file = "#{$RESO_MIX_PROCESSOR_ROOT}/mixes/#{uuid}/preview.wav"
        mix_ogg_file = "#{$RESO_MIX_PROCESSOR_ROOT}/mixes/#{uuid}/preview.ogg"
        mix_thumb_file = "#{$RESO_MIX_PROCESSOR_ROOT}/mixes/#{uuid}/thumb.jpg"
        mix_json_file = "#{$RESO_MIX_PROCESSOR_ROOT}/mixes/#{uuid}/mix.json"

        if File.exists? mix_zip_file

          #1) unzip into directory of the same uuid
          `unzip #{mix_zip_file} -d #{mix_tmp_dir}`

          if File.exists? mix_wav_file

            #2) convert preview wav to ogg
            `oggenc #{mix_wav_file} -q 5 -o #{mix_ogg_file}`

            if File.exists? mix_ogg_file
              
              #3) upload files to S3
              bucket = Settings.S3.bucket
              preview = "mixes/#{uuid}/preview"
              AWS::S3::S3Object.store(preview, File.open(mix_ogg_file), bucket, :access => :public_read)
              thumb = "mixes/#{uuid}/thumb"
              AWS::S3::S3Object.store(thumb, File.open(mix_thumb_file), bucket, :access => :public_read)
              mix = "mixes/#{uuid}/mix"
              AWS::S3::S3Object.store(mix, File.open(mix_json_file), bucket, :access => :public_read)
            end
          end
        end

        #4) update mix record to processed
        updated = conn.exec("update mixes set state = #{PROCESSED} where uuid = '#{uuid}'")
        output += "\n#{uuid}"

        #5) cleanup
        if File.exists? mix_tmp_dir then FileUtils.rm_rf(mix_tmp_dir) end
        if File.exists? mix_zip_file then File.delete mix_zip_file end
      end

      Pony.mail({
          :to => Settings.mailer.to,
          :from => Settings.mailer.from,
          :subject => "ResoMixProcessor (Finished)",
          :body => output,
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
    end
  end
end