require 'thor'
require 'fileutils'

# Require all .rb files in the layered_stack_rails folder recursively
Dir[File.join(__dir__, 'layered_stack_rails/**/*.rb')].each { |file| require_relative file }

module LayeredStackRails
  class Cli < Thor
    desc "generate", "Generates resources from app.yml"
    def generate
      LayeredStackRails::Generate.execute
    end
  end
end
