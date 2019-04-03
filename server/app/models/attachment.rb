class Attachment
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :type, :integer
  attribute :name, :string
  attribute :path, :string
  attribute :size, :integer
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  extend Enumerize
  enumerize :type, in: { directory: 1, file: 2 }

  class << self
    def list(options)
      base_path = Settings.attachment.base_path  
      path = File.join(base_path, options[:path].to_s, '/*')

      results = Dir.glob(path, File::FNM_DOTMATCH).reject { |x| x =~ /\.$/ }
      attachemnts =
        results.each_with_object([]) do |result, objects|
          stat = File.stat(result)
          object =
            if stat.directory?
              Attachment.new(
                type: 'directory', name: File.basename(result),
                path: result.sub(base_path, ''), size: nil,
                created_at: stat.ctime, updated_at: stat.mtime
              )
            elsif stat.file?
              Attachment.new(
                type: 'directory', name: File.basename(result),
                path: result.sub(base_path, ''), size: stat.size,
                created_at: stat.ctime, updated_at: stat.mtime
              )
            end
          objects << object if object.present?
        end
      attachemnts.sort_by { |item| [item.type.value, item.name] }
    end
  end

  def as_api_json
    { type: self.type, name: self.name, path: self.path, size: self.size,
      created_at: self.created_at, updated_at: self.updated_at}
  end
end