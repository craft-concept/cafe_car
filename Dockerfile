# Dockerfile for the CafeCar live demo (the test/dummy Rails app).
#
# Build context MUST be the repo root: the dummy app loads the gem from source
# via `gemspec` in the Gemfile, so the whole repo has to be present.
#
#   docker build -t cafe-car-demo .
#
# The container reseeds an ephemeral SQLite database on every boot, so the
# public demo self-heals after visitors poke at it.
FROM ruby:3.3.5-slim

# Runtime + build deps. libvips powers image_processing (avatar variants);
# sqlite3 is the demo database; git/build-essential build native gems.
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      git \
      curl \
      pkg-config \
      libyaml-dev \
      libsqlite3-dev \
      libvips \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Do NOT set WEB_CONCURRENCY here: Puma reads it natively and boots a *cluster*
# with that many workers (even WEB_CONCURRENCY=1 → cluster-mode-with-1-worker,
# carrying master-process overhead). Leaving it unset lets the demo boot true
# single-process — test/dummy/config/puma.rb only opts into cluster mode when an
# explicit WEB_CONCURRENCY > 1 is provided. This keeps the demo within the
# Railway memory cap (one worker per host core was the original 3GB+ RSS bug).
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development \
    BUNDLE_PATH=/usr/local/bundle \
    RAILS_SERVE_STATIC_FILES=1 \
    RAILS_LOG_TO_STDOUT=1

# Copy the whole repo (the gem source is the app's dependency) and install gems.
COPY . .
RUN bundle install && bundle clean --force

# Precompile assets into test/dummy/public/assets at build time.
# SECRET_KEY_BASE_DUMMY lets Rails boot for asset compilation without a real key.
WORKDIR /app/test/dummy
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
WORKDIR /app

EXPOSE 3000

# Prepare + seed the ephemeral DB, then boot Puma. Runs on every container start.
CMD ["bin/railway-demo"]
