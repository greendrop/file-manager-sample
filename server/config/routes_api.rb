# frozen_string_literal: true

module RoutesApi
  # extend された時、 draw のブロックを extend 元のスコープで実行する
  def self.extended(router)
    router.instance_exec(&@block) if @block
  end

  # ルーティングを登録する
  def self.draw(&block)
    @block = block
  end

  draw do
    namespace :v1 do
      resources :files, only: [] do
        collection do
          get :list
          get :get
          get :download
          post :create_directory
          post :delete
        end
      end
    end
  end
end
