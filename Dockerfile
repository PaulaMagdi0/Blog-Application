# Use Ruby base image
FROM ruby:3.2

# Install dependencies (including libvips for ruby-vips)
RUN apt-get update -qq && \
    apt-get install -y nodejs npm postgresql-client libvips-dev

# Set working directory
WORKDIR /app

# Copy only Gemfile first (to optimize caching)
COPY Gemfile ./

# Ensure the platform is added inside Docker
RUN gem install bundler && \
    bundle lock --add-platform x86_64-linux

# Copy Gemfile.lock (after ensuring it exists)
COPY Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application source code
COPY . .

# Expose Rails port
EXPOSE 3000

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
