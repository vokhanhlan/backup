module SnsPost
  extend ActiveSupport::Concern
  
  def twitter_photo_post(tweet_text,photo_path)
    begin
      OpenURI::Buffer.__send__ :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
      OpenURI::Buffer.const_set 'StringMax', 0
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_KEY']
        config.consumer_secret     = ENV['TWITTER_SECRET']
        config.access_token        = session[:oauth_token]
        config.access_token_secret = session[:oauth_token_secret]
      end
      client.update_with_media(tweet_text, open(photo_path))
    rescue => e
      flash[:errors] = [e.message]
    end
  end
end
