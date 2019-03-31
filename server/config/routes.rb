# frozen_string_literal: true

require_relative 'routes_api'

Rails.application.routes.draw do
  # Api
  namespace :api, path: :api, as: :api do
    extend RoutesApi
  end
end
