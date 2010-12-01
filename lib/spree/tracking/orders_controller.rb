module Spree::Tracking::OrdersController
  def self.included(target)
    target.class_eval do
      def tracking
        @order = Order.find_by_number(params[:id])
      end
      def reload_tracking
        @order = Order.find_by_number(params[:id])
        partner_name = @order.shipment.shipping_method.name
        if partner_name == "DPD"
          @order.shipment.reload_dpd
        elsif partner_name == "DHL Packstation"
          @order.shipment.reload_dhl
        end
        redirect_to tracking_admin_order_path(@order)
      end
    end
  end
end
