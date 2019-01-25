class Admin::CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy]

  # GET /admin/cards
  # GET /admin/cards.json
  def index
    authorize Card
    @cards = Card.all
  end

  # GET /admin/cards/1
  # GET /admin/cards/1.json
  def show
    authorize @card
  end

  # GET /admin/cards/new
  def new
    authorize Card
    @card = Card.new
  end

  # GET /admin/cards/1/edit
  def edit
    authorize @card
  end

  # POST /admin/cards
  # POST /admin/cards.json
  def create
    authorize Card
    @card = Card.new(card_params)

    respond_to do |format|
      if @card.save
        format.html { redirect_to admin_card_path(@card), notice: 'Card was successfully created.' }
        format.json { render :show, status: :created, location: @card }
      else
        format.html { render :new }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/cards/1
  # PATCH/PUT /admin/cards/1.json
  def update
    authorize @card
    respond_to do |format|
      if @card.update(card_params)
        format.html { redirect_to admin_card_path(@card), notice: 'Card was successfully updated.' }
        format.json { render :show, status: :ok, location: @card }
      else
        format.html { render :edit }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/cards/1
  # DELETE /admin/cards/1.json
  def destroy
    authorize @card
    @card.destroy
    respond_to do |format|
      format.html { redirect_to admin_cards_url, notice: 'Card was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_params
      params.require(:card).permit(:pan, :expiration, :cvc)
    end
end
