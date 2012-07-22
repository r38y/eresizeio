# repeat 10 (curl http://localhost:9292/photos/4215/original/photo.JPG &)
require 'mini_magick'
require 'sinatra/synchrony'

class Erio < Sinatra::Base
  register Sinatra::Synchrony
  ORIGIN = 'http://loseitorloseit.com'.freeze

  get '/' do
    'Hi there'
  end

  get '/*' do
    image.resize dimensions

    image.write(destination_path)

    send_file destination_path
  end

  def dimensions
    if params[:w] || params[:h]
      [params[:w], params[:h]].join('x')
    else
      '300x'
    end
  end

  def filename
    File.basename(source)
  end

  def destination_path
    File.join(Dir.tmpdir, filename)
  end

  def image
    @aimage ||= begin
      http = EM::Synchrony.sync EventMachine::HttpRequest.new(source).get
      MiniMagick::Image.read(http.response)
    end
  end

  def path
    params[:splat].first
  end

  def source
    File.join(ORIGIN, path)
  end
end
