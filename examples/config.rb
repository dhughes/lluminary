require 'dotenv'
Dotenv.load

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'lluminary'

Lluminary.configure do |config|
  config.provider(:openai, api_key: ENV['OPENAI_API_KEY'], model: 'gpt-4o')
  
  config.provider(:bedrock, 
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region: ENV['AWS_REGION'],
    model_id: 'meta.llama3-8b-instruct-v1:0'
  )
end

