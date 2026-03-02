namespace :tailwindcss do
  desc "Build Tailwind CSS for ActiveAdmin"
  task :build_active_admin do
    input = Rails.root.join("app/assets/tailwind/active_admin.css")
    output = Rails.root.join("app/assets/builds/active_admin.css")

    sh "bundle", "exec", "tailwindcss", "-i", input.to_s, "-o", output.to_s, "--minify"
  end

  desc "Watch Tailwind CSS for ActiveAdmin"
  task :watch_active_admin do
    input = Rails.root.join("app/assets/tailwind/active_admin.css")
    output = Rails.root.join("app/assets/builds/active_admin.css")

    exec "bundle exec tailwindcss -i #{input} -o #{output} --watch"
  end
end

Rake::Task["assets:precompile"].enhance(["tailwindcss:build_active_admin"]) if Rake::Task.task_defined?("assets:precompile")
