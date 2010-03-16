class ExpensesController < ApplicationController
# caches_action :index,
#               :cache_path => Proc.new { |controller|
#                 user   = controller.__send__(:current_user)
#                 format = controller.request.format.to_sym

#                 "index/user-#{user.id}.#{format}"
#               }

  # List recent expenses.
  def index
    load_expenses_and_averages

    @groups = @expenses.find_recent_grouped_by_relative_date
  end

  # Display new expense form.
  def new
    @expense = current_user.expenses.build
  end

  # Attempt to create an expense.
  #
  # If successful redirect, otherwise display the new
  # expense form.
  def create
    @expense = current_user.expenses.build(params[:expense])

    if @expense.save
      expire_fragment %r{index/user/#{current_user.id}\..*}

      redirect_to '/'
    else
      respond_to do |format|
        format.html   { render :action => :new }
        format.iphone { redirect_to '/' }
      end
    end
  end

  # Search expenses.
  def search
    load_expenses_and_averages

    @query  = params[:search][:query]
    @groups = Expense.search_grouped_by_relative_date(@query)
  end

  protected

  # Load the generally required objects.
  def load_expenses_and_averages
    @expense  = current_user.expenses.build
    @expenses = current_user.expenses
    @averages = {
      :day   => @expenses.calculate_average_for(:day),
      :week  => @expenses.calculate_average_for(:week),
      :month => @expenses.calculate_average_for(:month)
    }
  end
end
