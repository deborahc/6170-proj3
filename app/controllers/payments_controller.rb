class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :edit, :update, :destroy]

  before_action :check_owner, only: [:edit, :update, :destroy]
  before_action :check_access, only: [:show]

  # GET /payments
  # GET /payments.json
  def index
    @payments = current_user.payments
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new

    @pre_selected_event = get_event_id_from_param(params[:event_id])
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  # POST /payments.json
  def create
    event_id = payment_params[:event_id]
    @event = Event.find(event_id)

    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        # Distribute payment among users
        @payment.distribute_payment(payment_params[:user_id], payment_params[:amount])
        @payment.event.user_event_balances.each do |ueb|
          ueb.update_debt
          # Distribute payment made by the sender
          ueb.update_credit
        end
        format.html { redirect_to @event, success: 'Payment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment }
      else
        format.html { render action: 'new' }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1
  # PATCH/PUT /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment, success: 'Payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.require(:payment).permit(:amount, :description, :event_id, :user_id)
    end

    def check_owner
      unless false # @payment.user_id == current_user.id
        redirect_to :back, :notice => "You can't access this page"
      end
    end

    def check_access
      unless get_users_in_event(@payment.event).include? current_user.id
        redirect_to root_url, :notice => "You can't access this page"
      end
    end
end
