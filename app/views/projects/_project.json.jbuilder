json.extract! project, :id, :state, :name, :description, :baseline, :savings, :start_on, :end_on, :created_at, :updated_at
json.url project_url(project, format: :json)
