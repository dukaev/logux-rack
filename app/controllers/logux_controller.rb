# frozen_string_literal: true

class LoguxController < ActionController::Base
  include ActionController::Live

  # rubocop:disable Style/RescueStandardError
  def create
    Logux.verify_request_meta_data(meta_params)
    Logux.process_batch(command_params) do |processed|
      response.stream.write(processed)
    end
  rescue => e
    Logux.logger.error(e)
    response.stream.write([:internal_error].to_json)
  ensure
    response.stream.close
  end
  # rubocop:enable Style/RescueStandardError

  private

  def logux_params
    params.to_unsafe_h
  end

  def meta_params
    logux_params&.slice(:version, :password)
  end

  def command_params
    logux_params&.dig(:commands)
  end
end
