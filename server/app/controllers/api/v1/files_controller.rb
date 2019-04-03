module Api
  module V1
    class FilesController < Api::BaseController
      # 一覧
      def list
        attachments = Attachment.list(params)
        render json: attachments.map(&:as_api_json)
      end
    end
  end
end