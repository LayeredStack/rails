require "rails"
require "rails/generators"
require "yaml"

class LayeredStackRails::ScaffoldGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)
  argument :model_name, type: :string

  def execute
    yaml_content = YAML.load_file(File.join("app.yml"))

    model_data = yaml_content["resources"][model_name]
    if model_data
      puts "Generating model #{model_name} with attributes: #{model_data["attributes"]}"
      generate_scaffold(model_name, model_data["attributes"], model_data["associations"])
    else
      puts "Model #{model_name} not found in app.yml"
    end
  end

  def create_model_file
    template "active_record/model/model.erb", File.join("app/models", "#{model_name}.rb")
  end

  private

  def generate_scaffold(model_name, attributes, associations)
    @attributes = attributes.map do |name, details|
      if details['password_digest']
        "#{name}:digest"
      elsif details['token']
        "#{name}:token"
      else
        attribute_string = if details['type'] == 'decimal'
                             precision = details['precision']
                             scale = details['scale']
                             "#{name}:decimal{#{precision}.#{scale}}"
                           else
                             type = details['type']
                             limit = details['limit']
                             limit_string = limit ? "{#{limit}}" : ""
                             "#{name}:#{type}#{limit_string}"
                           end

        attribute_string += ":index" if details['index'] == true
        attribute_string += ":uniq" if details['index'] == 'uniq'

        attribute_string
      end
    end.join(" ")

    @class_name = model_name.classify

    @validations = []
    attributes.each do |name, details|
      if details['required']
        @validations << "validates :#{name}, presence: true"
      end
      if details['type'] == 'integer'
        @validations << "validates :#{name}, numericality: { only_integer: true }"
      end
      if details['precision'] && details['scale']
        @validations << "validates :#{name}, numericality: true"
      end
    end

    @associations = []
    associations.each do |name, details|
      case details['type']
      when 'has_many'
        if details['through']
          @associations << "has_many :#{name}, through: :#{details['through']}"
        else
          @associations << "has_many :#{name}"
        end
      when 'belongs_to'
        @associations << "belongs_to :#{name}"
      end
    end if associations

    # Generate the scaffold command
    invoke "rails:scaffold", [model_name.camelize, *@attributes.split(" "), "--api"], force: true

    # ToDo: Write a custom generator that avoids this workaround
    # Delete the model file after scaffolding to avoid duplicate model files
    model_file_path = File.join("app/models", "#{model_name}.rb")
    File.delete(model_file_path) if File.exist?(model_file_path)
  end
end
