# frozen_string_literal: true

class Attachment
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :type, :integer
  attribute :name, :string
  attribute :sort_name, :string
  attribute :path, :string
  attribute :size, :integer
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  extend Enumerize
  enumerize :type, in: { directory: 1, file: 2 }

  class << self
    def list(options) # rubocop:disable Metrics/MethodLength
      base_path = Settings.attachment.base_path
      path = File.join(base_path, options[:path].to_s, '/*')

      results = Dir.glob(path, File::FNM_DOTMATCH).reject { |x| x =~ /\.$/ }
      attachemnts =
        results.each_with_object([]) do |result, objects|
          stat = File.stat(result)
          object =
            if stat.directory?
              name = File.basename(result)
              sort_name = "#{Attachment.type.find_value('directory').value}-#{name}"
              Attachment.new(
                type: 'directory', name: name, sort_name: sort_name,
                path: result.sub(base_path, ''), size: nil,
                created_at: stat.ctime, updated_at: stat.mtime
              )
            elsif stat.file?
              name = File.basename(result)
              sort_name = "#{Attachment.type.find_value('file').value}-#{name}"
              Attachment.new(
                type: 'file', name: name, sort_name: sort_name,
                path: result.sub(base_path, ''), size: stat.size,
                created_at: stat.ctime, updated_at: stat.mtime
              )
            end
          objects << object if object.present?
        end
      attachemnts.sort_by { |item| [item.type.value, item.name] }
    end

    def create_directory(path)
      FileUtils.mkdir_p(path)
    end

    def delete(path)
      if File.file?(path)
        FileUtils.rm_f(path)
      elsif File.directory?(path)
        FileUtils.rm_rf(path)
      end
    end
  end

  def as_api_json
    url = Rails.application.routes.url_helpers.get_api_v1_files_url(
      host: Settings.url.api.host, port: Settings.url.api.port, path: path
    )
    download_url = Rails.application.routes.url_helpers.download_api_v1_files_url(
      host: Settings.url.api.host, port: Settings.url.api.port, path: path
    )
    { type: type, name: name, sort_name: sort_name,
      path: path, size: size, url: url, download_url: download_url,
      created_at: created_at, updated_at: updated_at }
  end
end
