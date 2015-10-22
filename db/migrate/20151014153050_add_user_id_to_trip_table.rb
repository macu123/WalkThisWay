class AddUserIdToTripTable < ActiveRecord::Migration
  def change
  	add_reference :trips, :user, index: true
  	add_column :trips, :start_latitude, :decimal, {:precision=>10, :scale=>6}
  	add_column :trips, :start_longitude, :decimal, {:precision=>10, :scale=>6}
  	add_column :trips, :end_latitude, :decimal, {:precision=>10, :scale=>6}
  	add_column :trips, :end_longitude, :decimal, {:precision=>10, :scale=>6}
  	add_column :trips, :startpoint, :string
  	add_column :trips, :endpoint, :string
  end
end
