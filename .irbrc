# Disable autocomplete suggestions
IRB.conf[:USE_AUTOCOMPLETE] = false

# Optional: Add some helpful IRB configurations
IRB.conf[:SAVE_HISTORY] = 200
IRB.conf[:HISTORY_FILE] = "#{ENV["HOME"]}/.irb-history"

require "pry-byebug"

# Require Lluminary
require "lluminary"

# Load the configuration file from examples
require_relative "examples/config"
