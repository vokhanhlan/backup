namespace :experience do
  desc "re-culculate experience scores."
  task refresh_score: :environment do
    begin
      puts "Re-culculate scores in all experiences.".yellow
      Experience.import culculated_exps.to_a, on_duplicate_key_update: [:score]
      puts "\nRe-culculate was succeed.".green
    rescue => ex
      puts ex.inspect.red
      puts "\nFailed to re-culculate scores.".red
    end
  end

  def culculated_exps
    exps = []
    puts "  Set culculated experiences."
    Experience.all.each do |exp|
      exp.score = Clicking.calculate_score(exp)
      exps << exp
      puts "    ID: #{exp.id}, score: before=#{exp.score_was}, after=#{exp.score}"
    end
    puts "  done. Bulk update to experiences."
    return exps
  end
end
