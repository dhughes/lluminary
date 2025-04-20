# Load the configuration file from examples
require_relative "examples/config"

# Require Lluminary
require "lluminary"

require "pry-byebug"

# Disable autocomplete suggestions
IRB.conf[:USE_AUTOCOMPLETE] = false

# Optional: Add some helpful IRB configurations
IRB.conf[:SAVE_HISTORY] = 200
IRB.conf[:HISTORY_FILE] = "#{ENV["HOME"]}/.irb-history"
