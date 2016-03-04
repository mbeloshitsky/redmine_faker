namespace :faker do
  desc 'Populate database with fake data'
  task :reset_and_populate => :environment do
    unless Rails.env.test? or Rails.env.development?
      puts "This task can only be run in test or development environment"
      exit
    end
    ENV['REDMINE_LANG'] ||= 'en'
    Faker::Config.locale = ENV['REDMINE_LANG']
    system("RAILS_ENV=#{Rails.env} rake db:drop")
    system("RAILS_ENV=#{Rails.env} rake generate_secret_token")
    system("RAILS_ENV=#{Rails.env} rake db:migrate")
    system("RAILS_ENV=#{Rails.env} REDMINE_LANG=#{ENV['REDMINE_LANG']} rake redmine:load_default_data")
    100.times do
        first_name = Faker::Name.first_name[0..12]
        last_name  = Faker::Name.last_name[0..12]
        name = "#{first_name} #{last_name}"
        #passwd = Faker::Internet.password(8)
        u=User.new
        u.firstname   = first_name 
        u.lastname    = last_name 
        u.login       = Faker::Internet.user_name(name)
        #u.password              = passwd
        #u.password_confirmation = passwd
        u.mail = Faker::Internet.email(last_name)
        u.mail_notification = Setting.default_notification_option
        u.save!
    end
    100.times do |i|
      p = Project.new
      p.name        = Faker::Company.name
      p.description = Faker::Company.catch_phrase
      p.identifier  = 'project' + i.to_s
      if rand < 0.7
        offset = rand(Project.count)
        p.parent = Project.offset(offset).first
      end
      p.save! 
    end
  end
end
