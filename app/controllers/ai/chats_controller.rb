# frozen_string_literal: true

module Ai
  class ChatsController < ApplicationController
    skip_forgery_protection

    def create
      unless params[:message].present?
        render json: { error: "message is required" }, status: :unprocessable_entity and return
      end

      response = Ai::Assistant.new(message: params[:message].to_s).call
      render json: response
    end
  end
end
