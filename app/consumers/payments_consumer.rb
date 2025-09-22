# frozen_string_literal: true

class PaymentsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      # Kafka communication demo
      Rails.logger.info "[Kafka] Message consumed: #{message.payload}. Customer Notified."
    end
  end
end
