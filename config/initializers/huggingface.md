HuggingFace.configure do |config|
  config.api_key = ENV.fetch("HUGGING_FACE_API_KEY")
end
