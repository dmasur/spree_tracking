require 'net/http'
require 'csv'
require 'xmlsimple'
module Spree::Tracking::Shipment
  def self.included(target)
    target.class_eval do
      has_many :tracking_events
      def reload_dpd
        begin
          csv = Net::HTTP.get 'extranet.dpd.de', '/cgi-bin/delistrack?pknr='+tracking+'&typ=10&lang=en'
          first = true
          CSV::Reader.parse(csv) do |row|
            if first
              first = false
              next
            end
            break unless row[1]
            row[1] = row[1].rjust(8,"0")
            row[2] = row[2].rjust(4,"0")
            day = row[1][0..1].to_i
            month = row[1][2..3].to_i
            year = row[1][4..8].to_i
            hour = row[2][0..1].to_i
            minute = row[2][2..4].to_i
            datetime = DateTime.civil(year,month,day,hour,minute)
            unless tracking_events.exists? :event_date => datetime, :event_type => row[5]
              tracking_event = tracking_events.build :event_date => datetime,
                :event_type => row[5],
                :depot => row[3],
                :city => row[4],
                :delivered_to => row[10]
              tracking_event.save
            end
          end
        rescue
        end
      end
      def reload_dhl
        tracking = self.tracking.gsub(" ","").gsub(".","")
        url = "http://nolp.dhl.de/nextt-online-public/direct/nexttjlibpublicservlet?xml=<?xml version='1.0' encoding='ISO-8859-1'?><data  appname='nol-public' password='anfang' request='get-status-for-public-user' language-code='de'><data piece-code=\"#{tracking}\"></data></data>"
        url = URI.encode(url)
        xml_data = Net::HTTP.get_response(URI.parse(url)).body
        data = XmlSimple.xml_in(xml_data)["data"].first["data"].first
        unless data["error"]
          datetime = DateTime.parse(data["last-event-timestamp"])
          unless tracking_events.exists? :event_date => datetime, :event_type => data["status"]
            tracking_event = tracking_events.build :event_date => datetime,
              :event_type => data["status"],
              :depot => data["leitcode"],
              :city => data["pan-recipient-city"],
              :delivered_to => data["recipient-name"]
            tracking_event.save
          end
        end
      end
    end
  end
end
