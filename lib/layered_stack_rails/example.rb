require 'thor'
require 'logger'

module LayeredStackRails
  class Example < Thor
    def self.execute
      new.execute
    end

    no_commands do
      def execute
        logger.info("> layered_stack-rails/example")

        # Ensure the directory exists
        directory_path = 'layered_stack'
        unless File.directory?(directory_path)
          FileUtils.mkdir_p(directory_path)
        end

        # Create the example product.yml file
        example_product = File.join(directory_path, 'resources.yml')
        unless File.exist?(example_product)
          File.open(example_product, 'w') do |file|
            file.write(<<~YAML)
              resources:
                product:
                  attributes:
                    name:
                      type: string
                      required: true
                      index: uniq
                    description:
                      type: text
                    price:
                      type: decimal
                      precision: 10
                      scale: 2
                      required: true
                    stock_quantity:
                      type: integer
                      required: true
                  associations:
                    order_items:
                      type: has_many
                    orders:
                      type: has_many
                      through: order_items

                order:
                  attributes:
                    order_number:
                      type: string
                      required: true
                      index: uniq
                    order_date:
                      type: datetime
                      required: true
                    total_amount:
                      type: decimal
                      precision: 10
                      scale: 2
                      required: true
                  associations:
                    order_items:
                      type: has_many
                    products:
                      type: has_many
                      through: order_items

                order_item:
                  attributes:
                    quantity:
                      type: integer
                      required: true
                    price:
                      type: decimal
                      precision: 10
                      scale: 2
                      required: true
                  associations:
                    order:
                      type: belongs_to
                    product:
                      type: belongs_to
            YAML
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
