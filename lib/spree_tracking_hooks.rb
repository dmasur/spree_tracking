class SpreeTrackingHooks < Spree::ThemeSupport::HookListener
    insert_after :admin_order_tabs, 'admin/shared/tracking_tab'
    insert_after :account_my_orders, 'users/tracking_tables'
end