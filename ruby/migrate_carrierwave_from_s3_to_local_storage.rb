Attachment.all.each do |attachment|
  dir = Rails.root.to_s + '/tmp/uploads' + File.dirname(URI(attachment.file.url).path)
  FileUtils.mkdir_p(dir)
  next if attachment.file.file.send(:file).nil?
  FileUtils.mv(attachment.file.tap(&:cache!).cache_path, dir)
end
