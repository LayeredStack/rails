require 'thor'
require 'fileutils'

# Require all .rb files in the layered_stack_rails folder recursively
Dir[File.join(__dir__, 'layered_stack_rails/**/*.rb')].each { |file| require_relative file }

module LayeredStackRails
  class Cli < Thor
    desc "product", "Creates an example product.yml resource file in the layered_stack/resources directory"
    def example
      LayeredStackRails::Example.execute
    end

    desc "generate", "Generates resources from ./layered_stack/resources.yml"
    def generate
      LayeredStackRails::Generate.execute
    end

    desc "dev", "Run example and generate with 'product' as the name"
    def dev
      example
      generate
      system('rails db:migrate')
    end
  end
end
