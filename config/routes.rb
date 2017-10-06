Rails.application.routes.draw do
  devise_for :users, skip: [:sessions, :passwords, :registrations]
  api vendor_string: "issue_tracker", default_version: 1 do
    version 1 do
      cache as: 'v1' do
        resource :registrations, only: [:create, :destroy]
        resource :sessions, only: [:create, :destroy]
        resources :issues, except: [:new, :edit] do
          patch :assign, on: :member
          patch :set_state, on: :member
        end
      end
    end
  end
end
