# frozen_string_literal: true

module Api
  module V1
    class FilesController < Api::BaseController
      # 一覧
      def list
        attachments = Attachment.list(params)
        render json: attachments.map(&:as_api_json)
      end

      # ファイル取得
      def get
        path =
          Rails.root.join(
            (Rails.env.test? ? 'private_test' : 'private'),
            'attachments',
            params[:path].to_s.sub(%r{^/}, '')
          )

        if request.headers['HTTP_RANGE'] && !Rails.configuration.action_dispatch.x_sendfile_header
          size = File.size(path)
          bytes = Rack::Utils.byte_ranges(request.headers, size)[0]
          offset = bytes.begin
          length = bytes.end - bytes.begin + 1

          response.header['Accept-Ranges'] = 'bytes'
          response.header['Content-Range'] = "bytes #{bytes.begin}-#{bytes.end}/#{size}"
          response.header['Content-Length'] = length.to_s

          send_data IO.binread(path, length, offset), stream: true, disposition: 'inline', status: 206
        else
          send_file(path, filename: File.basename(path), disposition: 'inline')
        end
      end

      # ファイルダウンロード
      def download
        path =
          Rails.root.join(
            (Rails.env.test? ? 'private_test' : 'private'),
            'attachments',
            params[:path].to_s.sub(%r{^/}, '')
          )
        send_file(path, filename: File.basename(path), disposition: 'attachment')
      end
    end
  end
end
