require 'sinatra'
require 'json'

post '/event_handler' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
	@payload = JSON.parse(params[:payload])

  sha1 = OpenSSL::HMAC.hexdigest(HMAC_DIGEST, secret, body)
	repo_url = @payload['repository']['ssh_url']
  repo_name  = @payload['repository']['name']
	if env['X-GitHub-Event'] == 'ping'
		'pong'
	else
		branch = @payload['ref'].split('/').last
		puts 'building %s branch %s' % [repo, branch]
		if repo_name == 'Affektive' && branch == 'master'
			output =  `/bin/bash /data/www/affektive.agif.me/deploy.sh "#{branch}" "#{repo_url}"`
		end
		puts 'done building %s' % output
		"Build Complete! %s " % output
	end
end


def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end