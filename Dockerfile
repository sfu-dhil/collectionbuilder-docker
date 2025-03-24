# Jekyll  app
FROM ruby:3.4-bookworm
EXPOSE 4000
WORKDIR /app

# add system deps
RUN apt-get update \
    && apt-get -y install imagemagick ghostscript \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# imagemagick policy change to allow pdfs
COPY docker/image-policy.xml /etc/ImageMagick-6/policy.xml

# install ruby deps
COPY app/Gemfile /app/Gemfile.lock /app/
RUN bundle install

# add project files
COPY app /app

# start jekyll serve
CMD ["jekyll", "serve", "--host=0.0.0.0"]