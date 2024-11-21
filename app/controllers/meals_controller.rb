class MealsController < ApplicationController
  def suggest
    ingredients = params[:ingredients].reject(&:empty?) # Remove empty ingredients

    if ingredients.empty?
      @response = ["Please provide at least one ingredient."]
    else
      prompt = "Suggest three meals that include the ingredients: #{ingredients.join(' and ')}"

      # Initialize HuggingFace client
      client = HuggingFaceClient.new(ENV.fetch("HUGGING_FACE_API_KEY"))
      suggestions = client.generate_text(prompt)

      if suggestions.blank?
        @response = ["No suggestions available."]
      else
        @response = suggestions.split("\n").reject(&:blank?)
      end
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "suggestions",
          partial: "meals/suggestions",
          locals: { response: @response }
        )
      end
      format.html do
        flash[:notice] = "Suggestions generated successfully."
        redirect_to meals_path
      end
    end
  end
end
