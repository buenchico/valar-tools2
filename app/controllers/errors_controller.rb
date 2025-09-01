class ErrorsController < ApplicationController
  layout "errors"

  def not_found
    render status: 404
  end

  def internal_server
    render template: "errors/internal_server", status: 500
  end
 end
