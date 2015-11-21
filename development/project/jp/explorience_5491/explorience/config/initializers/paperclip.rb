case Rails.env
when "production", "staging", "beta"
  Paperclip::Attachment.default_options[:url]          = ':s3_domain_url'
  Paperclip::Attachment.default_options[:path]         = '/:class/:attachment/:id_partition/:style.:extension'
  Paperclip::Attachment.default_options[:s3_host_name] = 's3-ap-northeast-1.amazonaws.com'
  Paperclip::Attachment.default_options[:s3_protocol]  = :https
else
  Paperclip::Attachment.default_options[:url] = '/system/:class/:attachment/:id_partition/:style.:extension'
end
