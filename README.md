# Evented Image Resize Proxy

1. gem install bundler --pre
2. bundle
3. foreman start
4. ab -n 100 -c 25 http://0.0.0.0:5000/photos/4215/original/photo.JPG\?w\=300
5. ab -n 100 -c 25 http://0.0.0.0:5000/photos/4215/medium/photo.JPG\?w\=300

# Sync Version

There is a syncronous version in the "sync" branch

# Numbers

The async version can do 4-5x as many requests as the sync version.

# Production test

http://erio.herokuapp.com/photos/4215/original/photo.JPG?h=150
