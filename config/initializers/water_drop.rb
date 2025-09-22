$waterdrop_producer = WaterDrop::Producer.new do |config|
  config.deliver = true
  config.kafka = {
    "bootstrap.servers": "kafka:9093",
    "client.id": "rat-pay-producer",
    "acks": "all"
  }
end
