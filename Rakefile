desc 'Build and deploy'
task :default do
	# Settings
	ssh_key = '/Users/sparanoid/dropbox/sparanoid-web/~ssh/sparanoid-CA.pem'
	ssh_user = 'ec2-user@sparanoid.com'
	remote_root = '/usr/share/nginx/html/start'
	exclude_files = '--include=*.min.css --exclude=*.css'

	# Deploy
	puts 'Deploying to EC2...'
	system("jekyll --no-server --no-auto && rsync -avz --delete #{exclude_files} -e \"ssh -i #{ssh_key}\" _site/  #{ssh_user}:#{remote_root}")
	puts 'Deployed.'
end
