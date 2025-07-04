class ImageProcessingJob < ApplicationJob
  queue_as :default

  def perform(user)
    user.image.variant(resize: "300x300").processed if user.image.attached?
  end

end
