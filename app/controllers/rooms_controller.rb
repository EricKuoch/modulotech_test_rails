class RoomsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    @rooms = policy_scope(Room)
    @availables_rooms = get_available_rooms(params[:checkin], params[:checkout], params[:query])
  end

  def show
    @room = Room.find(params[:id])
    authorize @room
    @booking = Booking.new
    @bookings_dates = @bookings.map { |booking| { from:booking.checkin, to: booking.checkout } }
    @current_booking = Booking.find_by(user: current_user, room_id: @room)
  end

  def user_rooms
    authorize Room
    @rooms_as_host = current_user.rooms
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)
    @room.user_id = current_user.id
    authorize @room
    if @room.save
      redirect_to room_path(@room)
    else
      render 'user_rooms'
      flash.alert = "room not found."
    end
  end


  private

  def room_params
    params.require(:room).permit(:title, :description, :price, :room_type, :city, :country, :address, :user_id)
  end

  def get_available_rooms(check_in, check_out, query)
    sql_query = "city ILIKE :query OR country ILIKE :query"
    if query.present? && check_in.present? && check_out.present?
      booked_rooms_ids = Booking.booked_between(check_in, check_out).pluck(:room_id)
      @available_rooms = Room.where(sql_query, query: query).where.not(id: booked_rooms_ids)
    elsif query.present?
      @available_rooms = Room.where(sql_query, query: query)
    else 
      @available_rooms = Room.all
    end
  end

end
