require 'open-uri'

module CollectionBuilderRemoteCsv
  Jekyll::Hooks.register(:site, :after_init, priority: :high) do |site|
    metadata_file_url = ENV['METADATA_FILE_URL']
    metadata_file_path = "#{site.config['metadata']}.csv"

    # check if metadata file url env variable exists
    if metadata_file_url && metadata_file_path
      File.open("_data/#{metadata_file_path}", 'wb') do |file|
        file << URI.open(metadata_file_url).read
      end
    end
  end
end