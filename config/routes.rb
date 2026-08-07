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
  get 'etrm', to: 'etrm#index'
  get 'etrm/job_data', to: 'etrm#job_data'
  get 'etrm/case_data', to: 'etrm#case_data'
  get '*path', to: 'application#render404'
end
