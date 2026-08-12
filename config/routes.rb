# frozen_string_literal: true

Rails.application.routes.draw do
  root 'pages#main'
  resources :test_reports, only: %i[index show update] do
    collection do
      get ':id/round/:round', to: 'test_reports#show'
      post 'result/:result_id', to: 'test_reports#update'
    end
  end
  resources :test_suites, only: %i[index show]
  get 'monitoring', to: 'monitoring#index'
  get 'monitoring/job_data', to: 'monitoring#job_data'
  get 'monitoring/case_data', to: 'monitoring#case_data'
  get '*path', to: 'application#render404'
end
