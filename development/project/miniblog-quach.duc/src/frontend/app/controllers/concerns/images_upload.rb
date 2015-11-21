module  ImagesUpload
    extend ActiveSupport::Concern

    @file_directory = 'upload'

    def self.upload(class_entry, params_entry, entry_name)
      # TODO: create folder
      # FileUtils.mkdir_p(@file_directory)
      case entry_name
      when "avatar"
        if class_entry[:avatar_path]
          FileUtils.remove_file(Rails.root.join('public',@file_directory,class_entry[:avatar_path]))
        end
        file = params_entry[:avatar]
        file_name = entry_name+"_"+DateTime.now.strftime("%Y%m%d%H%M%S")+"."+file.original_filename.split('.')[-1]
        File.open(Rails.root.join('public',@file_directory,file_name), 'wb') do |f|
          f.write(file.read)
        end
        class_entry.update_attribute(:avatar_path, file_name)
      when "thumbnail"
        if class_entry[:thumbnail_path]
          FileUtils.remove_file(Rails.root.join('public',@file_directory,class_entry[:thumbnail_path]))
        end
        file = params_entry[:thumbnail]
        file_name = entry_name+"_"+DateTime.now.strftime("%Y%m%d%H%M%S")+"."+file.original_filename.split('.')[-1]
        File.open(Rails.root.join('public',@file_directory,file_name), 'wb') do |f|
          f.write(file.read)
        end
        class_entry.update_attribute(:thumbnail_path, file_name)
      end
    end

end
