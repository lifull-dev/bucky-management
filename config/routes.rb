# frozen_string_literal: true

Rails.application.routes.draw do
  root 'pages#main'
  resources :test_reports, only: %i[index show] do
    collection do
      get ':id/round/:round', to: 'test_reports#show'
    end
  end
  resources :test_suites, only: %i[index show]
  get '*path', to: 'application#render_404'
end
