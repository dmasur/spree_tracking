class TrackingEvent < ActiveRecord::Migration
  def self.up
    create_table :tracking_events  do |t|
      t.references :shipment
      t.datetime :event_date
      t.string :depot
      t.string :city
      t.string :event_type
      t.string :delivered_to
      t.timestamps
    end

  end

  def self.down
    drop_table :tracking_events
  end
end
