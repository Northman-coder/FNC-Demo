class Admin::SalesController < ApplicationController
  before_action :authenticate_admin!

  DAILY_CHOICES = [7, 30, 90].freeze
  MONTHLY_CHOICES = [3, 6, 12].freeze

  def index
    @today = Time.zone.today

    @daily_days = DAILY_CHOICES.include?(params[:daily_days].to_i) ? params[:daily_days].to_i : 30
    @monthly_months = MONTHLY_CHOICES.include?(params[:monthly_months].to_i) ? params[:monthly_months].to_i : 12

    @daily_sales = sales_by_day(days_back: @daily_days)
    @monthly_sales = sales_by_month(months_back: @monthly_months)

    @today_total = Order.where(status: "paid", created_at: @today.all_day).sum(:total_price)
    @month_total = Order.where(status: "paid", created_at: @today.beginning_of_month..@today.end_of_day).sum(:total_price)
  end

  private

  # Returns an array of hashes: [{ label: "2026-02-28", total: 123.45 }, ...]
  def sales_by_day(days_back:)
    start_date = Time.zone.today - (days_back - 1).days

    rows = Order
      .where(status: "paid", created_at: start_date.beginning_of_day..Time.zone.now)
      .group(Arel.sql("DATE(orders.created_at)"))
      .order(Arel.sql("DATE(orders.created_at) ASC"))
      .sum(:total_price)

    (0...days_back).map do |offset|
      date = start_date + offset.days
      {
        label: date.to_s,
        total: rows[date] || 0
      }
    end
  end

  # Returns an array of hashes: [{ label: "2026-02", total: 123.45 }, ...]
  def sales_by_month(months_back:)
    start_month = Time.zone.today.beginning_of_month - (months_back - 1).months

    # Use date_trunc for Postgres grouping; cast to date so keys are Date objects.
    rows = Order
      .where(status: "paid", created_at: start_month.beginning_of_day..Time.zone.now)
      .group(Arel.sql("DATE_TRUNC('month', orders.created_at)::date"))
      .order(Arel.sql("DATE_TRUNC('month', orders.created_at)::date ASC"))
      .sum(:total_price)

    (0...months_back).map do |offset|
      month_date = (start_month + offset.months).to_date
      {
        label: month_date.strftime("%Y-%m"),
        total: rows[month_date] || 0
      }
    end
  end
end
