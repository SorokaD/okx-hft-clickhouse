FROM timescale/timescaledb:2.23.0-pg16

RUN apt-get update \
 && apt-get install -y postgresql-16-cron \
 && rm -rf /var/lib/apt/lists/*
