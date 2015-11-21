# TODO HACK: 時間の関係上ベタ書きしています。要リファクタ。
# TODO HACK: 特に、同一namespaceで定義された変数、メソッドはどちらかにoverrideされるのでその点も踏まえてリファクタ
require 'csv'

class PhotoIdConvertFailed < StandardError; end

namespace :experience do
  desc "Refresh photo_id of experience_photos to latest photo_id."
  task refresh_image: :environment do
    @csv_file = 'db/experience_data_additional/20150423_refresh_experience_image.csv'
    @log_file = 'log/rake_refresh_exp_image.log'
    @logger = Logger.new(@log_file)
    puts "Proecess log output to #{@log_file}".yellow
    puts "Load CSV from #{@csv_file}\n".yellow
    exp_photos, old_photo_ids = stack_refreshing_exp_photos
    puts "Update photo_id to existing experience photos.".yellow
    ActiveRecord::Base.transaction do
      bulk_update_to_exp_photos(exp_photos)
      destroy_old_photos(old_photo_ids)
    end
    puts "Refresh photo_id to experience photos was succeed.".green
    output_refresh_photo_info('Results:')
    output_refresh_photo_info("  updated records: #{exp_photos.count}")
  end

  # Options:
  #   color         : Specify to std out message color
  #   no_return_code: Message output with no return code
  def output_refresh_photo_info(str, opt={})
    @logger.info str
    (opt[:color])? print("  #{str}".__send__(opt[:color].to_sym)) : print("  #{str}")
    puts "\n" unless opt[:no_return_code]
  end

  def stack_refreshing_exp_photos
    csv_file_path = Rails.root.join(@csv_file)

    puts "Generate experience_photos objects.".yellow
    output_refresh_photo_info("#{@csv_file} reading...")

    new_exp_photos = []
    old_photo_ids = []

    CSV.foreach(@csv_file, 'r') do |row|
      next if row.first[0] == '#'
      target_file_name = row.first
      photos = Photo.where(img_file_name: target_file_name).order(created_at: :desc)
      begin
        raise PhotoIdConvertFailed, "Threre is no photo data, file_name: #{target_file_name}" if photos.empty?
        raise PhotoIdConvertFailed, "Photo data count is too many or too less, file_name: #{target_file_name}, num: #{photos.count}" unless photos.count == 2
        exp_photo = ExperiencePhoto.find_by(photo_id: photos.last.id)
        raise PhotoIdConvertFailed, "There is no experience_photo data, file_name: #{target_file_name}" unless exp_photo
        exp_photo.photo_id = photos.first.id
        if exp_photo.photo_id_changed?
          new_exp_photos << exp_photo
          old_photo_ids << exp_photo.photo_id_was
          output_refresh_photo_info("Stacked object's photo_id: new: #{exp_photo.photo_id}, old: #{exp_photo.photo_id_was}, target: #{target_file_name}")
        else
          output_refresh_photo_info("New photo_id was already set, file_name: #{target_file_name}, id: #{exp_photo.photo_id}", color: 'yellow')
        end
      rescue PhotoIdConvertFailed => ex
        output_refresh_photo_info(ex.message, color: 'red')
      end
    end

    puts "Generate objects was done.\n".green
    return new_exp_photos, old_photo_ids
  end

  def bulk_update_to_exp_photos(exp_photos)
    if exp_photos.present?
      ExperiencePhoto.import exp_photos.to_a, on_duplicate_key_update: [:photo_id]
      output_refresh_photo_info("Bulk_update was succeed", color: 'green')
    else
      output_refresh_photo_info("There is no collection for Bulk_update.", color: 'yellow')
    end
  end

  def destroy_old_photos(old_photo_ids)
    if old_photo_ids.present?
      Photo.where(id: old_photo_ids).destroy_all
      output_refresh_photo_info("Destroy old photos was succeed", color: 'green')
    else
      output_refresh_photo_info("There is no collection for destroy old photos.", color: 'yellow')
    end
  end
end
