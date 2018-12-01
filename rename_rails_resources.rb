def exe(str)
  puts str
  `#{str}`
end

resources = ['events', 'projects', 'outdoors']

resources.each do |folder|
  resources = `ls app/controllers/#{folder}`.split.map(&:strip).map { |s| s.sub('_controller.rb', '') }
  resources.each do |resource|
    p resource
    old_controller_name = "#{resource.classify.pluralize}Controller"
    new_controller_name = "#{folder.capitalize}::#{old_controller_name}"
    exe("find ./app/controllers/ -type f -exec sed -i 's/class #{old_controller_name}/class #{new_controller_name}/g' {} \\;")
    exe("find ./spec/controllers/ -type f -exec sed -i 's/RSpec.describe #{old_controller_name}/RSpec.describe #{new_controller_name}/g' {} \\;")
    exe("mv app/views/#{resource} app/views/#{folder}/#{resource}")
    exe("find ./app/views/#{folder}/ -type f -exec sed -i 's/#{resource}\\//#{folder}\\/#{resource}\\//g' {} \\;")
    exe("sed -i 's/resources :#{resource}/resources :#{resource}, module: :#{folder}/' config/routes.rb")
    exe("mv spec/controllers/#{resource}_controller_spec.rb spec/controllers/#{folder}/#{resource}_controller_spec.rb")
    puts
    puts
  end
end
