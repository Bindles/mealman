require "httparty"
class HuggingFaceClient
  include HTTParty
  base_uri "https://api-inference.huggingface.co/models"

  def initialize(api_key)
    @headers = {
      "Authorization" => "Bearer #{api_key}",
      "Content-Type" => "application/json"
    }
  end

  def generate_text(prompt, model = "EleutherAI/gpt-neo-1.3B", max_length = 150)
    response = self.class.post(
      "/#{model}",
      headers: @headers,
      body: {
        inputs: prompt,
        parameters: {
          max_length: max_length,
          return_full_text: false
        }
      }.to_json
    )

    if response.success?
      Rails.logger.debug("HuggingFace API Response: #{response.body}")
      # Directly return the generated text from the response
      response.parsed_response.first["generated_text"] if response.parsed_response.is_a?(Array)
    else
      Rails.logger.error("HuggingFace API Error: #{response.body}")
      nil
    end
  rescue StandardError => e
    Rails.logger.error("HuggingFaceClient Error: #{e.message}")
    nil
  end
end
