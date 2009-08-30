# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def youtube_embed(youtube_url)
    youtube_id = youtube_url.match(/v=([^&]*)/)[1]
    <<-ENDOFHTML
    <object width="200" height="200">
      <param name="movie" value="http://www.youtube.com/v/#{youtube_id}"></param>
      <param name="allowFullScreen" value="true"></param>
      <embed src="http://www.youtube.com/v/#{youtube_id}"
        type="application/x-shockwave-flash"
        width="200" height="200" 
        allowfullscreen="true"></embed>
    </object>
    ENDOFHTML
  end
end
