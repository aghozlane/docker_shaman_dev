# Run the docker
chmod -R 777 /path/to/shaman
docker run --rm -p 80:80 -v /path/to/shaman:/srv/shiny-server/ aghozlane/shaman_dev
# Then connect to http://0.0.0.0/
