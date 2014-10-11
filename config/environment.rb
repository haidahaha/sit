# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ENV['SSL_CERT_FILE'] = File.expand_path('../cacert.pem', __FILE__)
