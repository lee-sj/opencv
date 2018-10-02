require 'opencv'
include OpenCV
class HomeController < ApplicationController

  def index
  end
  
  def photos
    
    data = '/usr/share/opencv/haarcascades/haarcascade_frontalface_alt.xml'
    detector = CvHaarClassifierCascade::load(data)
    image = CvMat.load(params[:input_file].path)
    detector.detect_objects(image).each do |region|
      color = CvColor::Blue
      image.rectangle! region.top_left, region.bottom_right, :color => color
    end
    image.save_image("output.jpg")
    # send_file("output.jpg")
    send_file("output.jpg", disposition: 'inline')
    # redirect_to root_path
  end
end
