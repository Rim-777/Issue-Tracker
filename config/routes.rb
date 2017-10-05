Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }
  api vendor_string: "issue_tracker", default_version: 1 do
    version 1 do
      cache as: 'v1' do
        resource :registrations, only: [:create, :destroy], as: :user
      end
    end
  end

end
