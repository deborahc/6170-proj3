class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  before_action :check_organizer_permissions, only: [:destroy, :edit, :update]
  before_action :check_show_permissions, only: [:show]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new

    @all_users = User.all

    @user_event_balance = @event.user_event_balances.build
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(:name => event_params[:name], :description => event_params[:description], :total_balance => 0, :organizer => current_user.id)

    params[:users][:id].each do |user|
      if !user.empty?
        @event.user_event_balances.build(:amount => 0, :user_id => user)
      end
    end

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @event }
      else
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:name, :description)
  end

  def check_organizer_permissions
    if @event.organizer != current_user.id
      redirect_to root_url, :notice => "You can't access this page"
    end
  end

  def check_show_permissions
    unless @event.organizer == current_user.id or @event.user_event_balances.user_id.include? current_user.id
      redirect_to root_url, :notice => "You can't access this page"
    end
  end
end
