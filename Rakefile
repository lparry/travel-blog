require "stringex_lite"

## -- Deploy Configs -- ##

 deploy_default = "push"
 deploy_branch  = "master"

## -- Misc Configs -- ##

public_dir      = "public"    # compiled site directory
source_dir      = "source"    # source file directory
deploy_dir      = "_deploy"   # deploy directory (for Github pages deployment)
# stash_dir       = "_stash"    # directory to stash posts for speedy generation
posts_dir       = "_posts"    # directory for blog files
drafts_dir      = "_drafts"    # directory for blog files
new_post_ext    = "markdown"  # default new post file extension when using the new_post task
server_port     = "4000"      # port for preview server eg. localhost:4000


# #######################
# # Working with Jekyll #
# #######################
#
desc "Generate jekyll site"
task :generate do
   system "jekyll build"
end

desc "preview the site in a web browser"
task :preview do
  system "jekyll serve --watch --drafts"
end

desc "preview the production site in a web browser"
task :preview_production do
  system "jekyll serve --watch"
end


desc "mark a post as published, update the dates"
task :publish_post, :filename do |t, args|
  raise "file not found" unless File.exist?(args[:filename])
  filename = args[:filename]
  time = Time.now
  lines = File.read(filename).lines

  line = lines.shift
  lines.unshift "date: #{time.strftime("%Y-%m-%d %H:%M") }\n"
  lines.unshift line

  title =  lines.select{|l| l =~ /title: /}.first.sub(/title: /, "").gsub(/"/,"").chomp.to_url

  new_filename = "#{source_dir}/#{posts_dir}/#{time.strftime("%Y-%m-%d")}-#{title.to_url}.markdown"

  File.open(filename, 'w') do |file|
    file.write(lines.join)
  end

  `git mv "#{filename}" "#{new_filename}"`
end

# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new post in #{source_dir}/#{drafts_dir}"
task :new_post, :title do |t, args|
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
  mkdir_p "#{source_dir}/#{posts_dir}"
  args.with_defaults(:title => 'new-post')
  title = args.title
  filename = "#{source_dir}/#{drafts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!")
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "tags: example, tag"
    post.puts "dont_cache_images: true"
    post.puts "---"
    post.puts "Intro"
    post.puts "<!-- more -->"
    post.puts "Body"
  end
end

# # usage rake isolate[my-post]
# desc "Move all other posts than the one currently being worked on to a temporary stash location (stash) so regenerating the site happens much quicker."
# task :isolate, :filename do |t, args|
#   stash_dir = "#{source_dir}/#{stash_dir}"
#   FileUtils.mkdir(stash_dir) unless File.exist?(stash_dir)
#   Dir.glob("#{source_dir}/#{posts_dir}/*.*") do |post|
#     FileUtils.mv post, stash_dir unless post.include?(args.filename)
#   end
# end
#
# desc "Move all stashed posts back into the posts directory, ready for site generation."
# task :integrate do
#   FileUtils.mv Dir.glob("#{source_dir}/#{stash_dir}/*.*"), "#{source_dir}/#{posts_dir}/"
# end
#
# ##############
# # Deploying  #
# ##############

desc "Default deploy task"
task :deploy do
  # ALWAYS regenerate to make sure nothing accidentally gets published
  Rake::Task[:generate].execute

  Rake::Task[:copydot].invoke(source_dir, public_dir)
  Rake::Task["#{deploy_default}"].execute
end

desc "Generate website and deploy"
task :gen_deploy => [:integrate, :generate, :deploy] do
end

desc "copy dot files for deployment"
task :copydot, :source, :dest do |t, args|
  FileList["#{args.source}/**/.*"].exclude("**/.", "**/..", "**/.DS_Store", "**/._*").each do |file|
    cp_r file, file.gsub(/#{args.source}/, "#{args.dest}") unless File.directory?(file)
  end
end

desc "deploy public directory to github pages"
multitask :push do
  puts "## Deploying branch to Github Pages "
  (Dir["#{deploy_dir}/*"]).each { |f| rm_rf(f) }
  Rake::Task[:copydot].invoke(public_dir, deploy_dir)
  puts "\n## copying #{public_dir} to #{deploy_dir}"
  cp_r "#{public_dir}/.", deploy_dir
  cd "#{deploy_dir}" do
    system "git add -A ."
    system "git add -u"
    puts "\n## Commiting: Site updated at #{Time.now.utc}"
    message = "Site updated at #{Time.now.utc}"
    system "git commit -m \"#{message}\""
    puts "\n## Pushing generated #{deploy_dir} website"
    system "git push origin #{deploy_branch} --force"
    puts "\n## Github Pages deploy complete"
  end
end

# desc "Update configurations to support publishing to root or sub directory"
# task :set_root_dir, :dir do |t, args|
#   puts ">>> !! Please provide a directory, eg. rake config_dir[publishing/subdirectory]" unless args.dir
#   if args.dir
#     if args.dir == "/"
#       dir = ""
#     else
#       dir = "/" + args.dir.sub(/(\/*)(.+)/, "\\2").sub(/\/$/, '');
#     end
#     rakefile = IO.read(__FILE__)
#     rakefile.sub!(/public_dir(\s*)=(\s*)(["'])[\w\-\/]*["']/, "public_dir\\1=\\2\\3public#{dir}\\3")
#     File.open(__FILE__, 'w') do |f|
#       f.write rakefile
#     end
#     compass_config = IO.read('config.rb')
#     compass_config.sub!(/http_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_path\\1=\\2\\3#{dir}/\\3")
#     compass_config.sub!(/http_images_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_images_path\\1=\\2\\3#{dir}/images\\3")
#     compass_config.sub!(/http_fonts_path(\s*)=(\s*)(["'])[\w\-\/]*["']/, "http_fonts_path\\1=\\2\\3#{dir}/fonts\\3")
#     compass_config.sub!(/css_dir(\s*)=(\s*)(["'])[\w\-\/]*["']/, "css_dir\\1=\\2\\3public#{dir}/css\\3")
#     File.open('config.rb', 'w') do |f|
#       f.write compass_config
#     end
#     jekyll_config = IO.read('_config.yml')
#     jekyll_config.sub!(/^destination:.+$/, "destination: public#{dir}")
#     jekyll_config.sub!(/^subscribe_rss:\s*\/.+$/, "subscribe_rss: #{dir}/atom.xml")
#     jekyll_config.sub!(/^root:.*$/, "root: /#{dir.sub(/^\//, '')}")
#     File.open('_config.yml', 'w') do |f|
#       f.write jekyll_config
#     end
#     rm_rf public_dir
#     mkdir_p "#{public_dir}#{dir}"
#     puts "## Site's root directory is now '/#{dir.sub(/^\//, '')}' ##"
#   end
# end

task :default => :preview
