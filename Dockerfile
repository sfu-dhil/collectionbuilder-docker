# Jekyll  app
FROM ruby:3.4-bookworm
EXPOSE 4000
WORKDIR /app

# add system deps
RUN apt-get update \
    && apt-get -y install imagemagick ghostscript \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# install ruby deps
COPY Gemfile Gemfile.lock ./
RUN bundle install

# add project files
COPY . /app

# start jekyll serve
CMD ["jekyll", "serve", "--host=0.0.0.0"]