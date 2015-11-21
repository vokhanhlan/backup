namespace :photo do
  desc "Re-upload existing photos to S3(when production) or public/system(when development)"
  task reupload_existing_photos: :environment do
    puts "Re-uploading existing photos".yellow
    Photo.find_each do |old_photo|
      if old_photo.img_file_name && old_photo.img_file_name.include?("experiences/")
        ActiveRecord::Base.transaction do
          new_file  = File.new("#{Rails.root}/app/assets/images/#{old_photo.img_file_name}")
          print "target : #{new_file.path} ... "
          new_photo = Photo.create(img: new_file)
          exp_photo = ExperiencePhoto.find_by(photo_id: old_photo.id)
          exp_photo.update_attributes(photo_id: new_photo.id)
          old_photo.destroy
          puts "done".green
        end
      end
    end
    puts ""
    puts "Re-uploading existing photos was succeed.".green
  end
end
