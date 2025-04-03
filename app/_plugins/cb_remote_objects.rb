require 'open-uri'
require 'uri'

module CollectionBuilderRemoteObjects
  Jekyll::Hooks.register(:site, :after_init, priority: :normal) do |site|
    metadata_file_path = "_data/#{site.config['metadata']}.csv"

    # check configured metadata exists
    if metadata_file_path && File.exist?(metadata_file_path)
      csv_text = File.read(metadata_file_path, encoding: 'utf-8')
      csv_contents = CSV.parse(csv_text, headers: true)

      # get all items with both object_download_remote_url and object_location values
      remote_files = csv_contents.select do |item|
        # item has a object remote url
        next unless item['object_download_remote_url']
        # object_download_remote_url is a url (!nil?)
        next unless !(item['object_download_remote_url'] =~ URI::regexp).nil?
        # item has a project location set
        next unless item['object_location']
        # object_location is not itself a remote url (nil?)
        next unless (item['object_location'] =~ URI::regexp).nil?
        # object_location file doesn't exist yet (remove leading '/' to use project relative paths)
        next unless !File.exist?(item['object_location'].delete_prefix('/'))
        next(true)
      end

      remote_files.each do |item|
        File.open(item['object_location'].delete_prefix('/'), 'wb') do |file|
          file << URI.open(item['object_download_remote_url']).read
        end
      end
    end
  end
end