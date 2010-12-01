require 'spree_core'
require 'spree_tracking_hooks'

module SpreeTracking
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
      Admin::OrdersController.send(:include, Spree::Tracking::OrdersController)
      Shipment.send(:include, Spree::Tracking::Shipment)
    end

    config.to_prepare &method(:activate).to_proc
  end
end
