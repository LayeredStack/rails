require 'thor'
require 'logger'
require 'yaml'
require 'rails'

module LayeredStackRails
  class Generate < Thor
    def self.execute
      new.execute
    end

    no_commands do
      def execute
        logger.info("> layered_stack-rails/generate_new")

        yaml_content = YAML.load_file(File.join("layered_stack", "resources.yml"))
        resources = yaml_content["resources"]
        resources.each do |model_name, model_data|
          if model_data
            system("rails generate layered_stack_rails:scaffold #{model_name}")
          else
            logger.error("Model #{model_name} not found in resources.yml")
          end
        end
      end

      private

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end
  end
end
