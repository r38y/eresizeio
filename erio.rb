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
    resize_image
    # https://github.com/igrigorik/em-synchrony
    send_file destination_path
  end

  def dimensions
    if params[:w] || params[:h]
      [params[:w], params[:h]].join('x')
    else
      '300x'
    end
  end

  def resize_image
    command_builder = MiniMagick::CommandBuilder.new(:mogrify)
    command_builder << image.path
    command_builder.resize dimensions
    # puts command_builder.command

    EM.synchrony do
      EM.system(command_builder.command) {|output, status|
      }
    end
    image.write(destination_path)
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
