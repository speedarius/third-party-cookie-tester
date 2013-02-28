class TestController < ApplicationController
  session :off
  before_filter :request_info
  
  def index
    render :text => "Hi, I'm #{@host}. I don't set any cookies or anything, except perhaps the rails default session cookie. But I do probably count as visiting #{request.host}"
  end

  def happy_cookie
    cookies["happy_cookie"] = "I love you!"
    render :text => "Hi, I am #{@host}, and I am setting a happy cookie."
  end
  
  def third_parties
  end
  
  def asset
    cookies["third_party_#{@host}"] = "I got you sucka! Love, #{@host} :)"
    render :js => "alert('Hello, I come from a js asset at #{@host}, and I try to set a third-party cookie');"
  end

  def redirect
    redirect_to @target
  end

  def open_window
  end
  
  def request_info
    @host = request.host
    @port = request.port
    @target = params[:target]
  end

end
