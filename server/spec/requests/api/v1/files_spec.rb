# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::FilesController, type: :request do
  include Committee::Rails::Test::Methods

  describe 'GET list_api_v1_files_url' do
    let(:attachments) do
      [
        Attachment.new(type: 'directory', name: 'directory', sort_name: '0-directory', path: 'directory', size: nil,
                       created_at: Time.zone.now, updated_at: Time.zone.now),
        Attachment.new(type: 'directory', name: 'file.txt', sort_name: '1-file.txt', path: 'file.txt', size: 1,
                       created_at: Time.zone.now, updated_at: Time.zone.now)
      ]
    end

    before do
      expect(Attachment).to receive(:list).and_return(attachments)
      get list_api_v1_files_url
    end

    it '正常に取得できること' do
      assert_schema_conform
    end
  end
end
