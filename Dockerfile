FROM ruby:2.5.3
# Update and install all of the required packages.
# At the end, remove the apk cache
RUN mkdir /usr/app
WORKDIR /usr/app
COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN gem install bundler
RUN bundle install
COPY . /usr/app
EXPOSE 4567
CMD ["bundle", "exec", "foreman", "start"]