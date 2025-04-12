Gem::Specification.new do |s|
  s.name        = 'lluminary'
  s.version     = '0.1.0'
  s.summary     = 'A framework for building LLM-powered applications'
  s.description = 'Lluminary is a framework for building applications that leverage Large Language Models. It provides a structured way to define tasks, manage prompts, and handle LLM interactions.'
  s.authors     = ['Your Name']
  s.email       = ['your.email@example.com']
  s.files       = Dir['lib/**/*', 'spec/**/*']
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.7.0'

  # Runtime dependencies
  s.add_runtime_dependency 'activemodel', '~> 7.1.0'
  s.add_runtime_dependency 'ruby-openai', '~> 6.3'  # Required for OpenAI provider
  s.add_runtime_dependency 'aws-sdk-bedrockruntime', '~> 1.0'  # Required for AWS Bedrock provider

  # Development dependencies
  s.add_development_dependency 'rspec', '~> 3.12'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rubocop', '~> 1.50'
  s.add_development_dependency 'dotenv', '~> 2.8'
  s.add_development_dependency 'pry-byebug', '~> 3.10'
end 