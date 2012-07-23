# repeat 10 (curl http://localhost:9292/photos/4215/original/photo.JPG &)
require 'mini_magick'
require 'sinatra/synchrony'
require 'em-synchrony/em-http'

def system_call(command)
  f = Fiber.current
  puts command
  EM.system(command) {|output, status|
    f.resume([ output, status ])
  }
  Fiber.yield
end

class Erio < Sinatra::Base
  register Sinatra::Synchrony
  ORIGIN = 'http://loseitorloseit.com'.freeze

  get '/' do
    'hi there'
  end

  get '/*' do
    http = EventMachine::HttpRequest.new(source).get
    image = MiniMagick::Image.read(http.response)

    command_builder = MiniMagick::CommandBuilder.new(:mogrify)
    command_builder.resize dimensions
    command_builder << image.path

    output = system_call(command_builder.command)

    image.write(destination_path)

    send_file destination_path
  end

  def dimensions
    if params[:w] || params[:h]
      [params[:w], params[:h]].join('x')
    else
      '300x100'
    end
  end

  def filename
    File.basename(source)
  end

  def destination_path
    File.join(Dir.tmpdir, filename)
  end

  # def image
  #   @image ||= begin
  #     http = EM::Synchrony.sync EventMachine::HttpRequest.new(source).get
  #     MiniMagick::Image.read(http.response)
  #   end
  # end

  def path
    params[:splat].first
  end

  def source
    File.join(ORIGIN, path)
  end
end
