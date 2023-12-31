class CoffeesController < ApplicationController
  before_action :set_coffee, only: %i[show edit update destroy]
  skip_before_action :authenticate_user!, only: :show

  def index
    @coffees = Coffee.all
    if params[:search].present?
      search_coffee
    end
  end

  def show
  end

  def new
    @coffee = Coffee.new
    # respond_to do |format|
    #   format.html
    #   format.js
    # end
  end

  def create
    @user = current_user
    @coffee = Coffee.new(coffee_params)
    @coffee.user = @user
    @coffee.save
    respond_to do |format|
      if @coffee.save
        format.turbo_stream { redirect_to coffee_path(@coffee.id) }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace('purchase-form', partial: "coffees/form",
          locals: { coffee: @coffee })
        }
      end
    end
    # if @coffee.save
    #   redirect_to coffees_path
    # else
    #   render :new, status: :unprocessable_entity
    # end
  end

  def edit
  end

  def update
    @coffee.update(coffee_params)

    redirect_to coffee_path(@coffee)
  end

  def destroy
    @coffee.destroy

    redirect_to coffees_path
  end

  def map
    @coffees = Coffee.all
    @markers = @coffees.geocoded.map do |coffee|
      {
        lat: coffee.latitude,
        lng: coffee.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: {coffee: coffee}),
        marker_html: render_to_string(partial: "marker")
      }
    end
  end

  def search_coffee
    PgSearch::Multisearch.rebuild(Coffee)
    results = PgSearch.multisearch(params[:search])
    @coffees = results.map { |result| result.searchable}
  end

  private

  def set_coffee
    @coffee = Coffee.find(params[:id])
  end

  def coffee_params
    params.require(:coffee).permit(:name, :origin, :strength, :rating, :description, :photo, :variety, :grind, :intensifier, :price)
  end
end
