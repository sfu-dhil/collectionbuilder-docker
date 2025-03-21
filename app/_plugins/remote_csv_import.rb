require 'open-uri'

module JekyllRemoteCsvImport
  Jekyll::Hooks.register(:site, :after_init, priority: :normal) do |site|
    metadata_file_url = ENV['METADATA_FILE_URL']
    metadata_file_name = ENV['METADATA_FILE_NAME'] || 'metadata.csv'

    # check if metadata file url env variable exists
    unless ENV['METADATA_FILE_URL']
      return
    end

    File.open("_data/#{metadata_file_name}", 'wb') do |file|
      file << URI.open(metadata_file_url).read
    end
  end
end