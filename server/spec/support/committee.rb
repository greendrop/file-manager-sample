# frozen_string_literal: true

require 'committee'
require 'committee/rails/test/methods'

RSpec.configure do |config|
  config.add_setting :committee_options
  config.committee_options = { schema_path: Rails.root.join('docs', 'api', 'schema.yml').to_s }
end
