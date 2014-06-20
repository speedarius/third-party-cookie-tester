class TestController < ApplicationController
  session :off
  before_filter :request_info
  
  def index
    message = "<p>Hi, I'm #{@host}. I don't set any cookies or anything. But I do probably count as visiting #{request.host}, for whatever that is worth.</p>"

    cookie_list = "<p>Cookies your browser sent me with this request:<p><ul>"
    cookies.each do |key, val|
      cookie_list += "<li>#{key}: #{val}</li>"
    end
    cookie_list += "</ul>"

    render :inline => "<p>#{message}</p>#{cookie_list}"
  end

  def happy_cookie
    cookies["happy_cookie"] = "I love you!"
    render :text => "Hi, I am #{@host}, and I am setting a happy cookie."
  end
  
  def third_party_script_tags
  end

  def third_party_iframes
  end
  
  def asset
    cookies["third_party_#{@host}"] = "I got you sucka! Love, #{@host} :)"
    respond_to do |format|
      format.js {
        render :js => "alert('Hello, I come from a js asset at #{@host}, and I try to set a third-party cookie');"
      }
      format.html {
        render :inline => "Hello, I come from an html asset at #{@host}, and I try to set a third-party cookie"
      }
    end
  end

  def redirect
    redirect_to @target
  end

  def open_window
  end

  def iframe
    if params[:hidden]
      render :inline => "<p>Hi, I am #{@host}. You don't see it, but this page has a tiny, hidden iframe to #{@target}.</p><iframe src=\"#{@target}\" height=\"1\" width=\"1\" style=\"display:none;\"></iframe>"
    else
      render :inline => "<iframe src=\"#{@target}\"></iframe>"
    end
  end
  
  def request_info
    @host = request.host
    @port = request.port
    @target = params[:target]
  end

end
