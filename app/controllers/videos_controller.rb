class VideosController < ApplicationController
  before_action :authenticate_user!

  def new
    @video = Video.new
  end

  def show
    @video = Video.find(params[:id])
  end

  def create
    # Redirect away if video exists in database already and is on a team
    redirect_to action: :show if (exists = Video.find_by_yt_id(video_params[:yt_id]) &&
                          exists.team_id.present? )
    # Otherwise create the video so it can be signed
    video_attributes = make_video(video_params[:yt_id])

    # Leave these here so more advanced functionality can be set later
    video_attributes.merge!({
                        salary: 10000000,
                        watches: 0
    })
    binding.pry
    video = Video.create(video_attributes)

    # Video exists now, so pass to videos#edit with team info so user can sign
    redirect_to :show
    redirect_to edit_team_video_path(current_user.team.id, video.id)
  end

  def edit
  end

  private

  def make_video(youtube_id)
    client = YouTubeIt::Client.new(dev_key: "AIzaSyDeEE8UySfWfxuO3hz_Qwsj4R3atx-OF70")
    video = client.video_by(youtube_id)

    attributes = {
                  yt_id: video.unique_id,
                  title: video.title,
                  initial_watches: video.view_count,
                  author: video.author.name,
                  uploaded_at: video.uploaded_at,
                  embed_html5: video.embed_html5,
                  description: video.description
                 }
    attributes
  end

  def video_params
    params.require(:video).permit(:yt_id)
  end
end

# Video Schema
#     t.integer  "salary"
#     t.integer  "initial_watches"
#     t.integer  "watches"
#     t.string   "yt_id"
#     t.string   "description"
#     t.datetime "uploaded_at"
#     t.string   "author"
#     t.string   "embed_html5"
#     t.integer  "team_id"
#     t.string   "title"