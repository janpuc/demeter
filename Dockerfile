#Stage 1 - Install dependencies and build the app
FROM debian:buster AS build

# Install flutter dependencies
RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter path
# RUN /usr/local/flutter/bin/flutter doctor -v
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor -v

# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container
RUN mkdir /app/
COPY . /app/
WORKDIR /app/
RUN flutter pub get

# Run test and send code coverage
RUN flutter analyze
RUN flutter test --coverage
RUN curl -s https://codecov.io/bash

# Run build
RUN flutter build web

# Stage 2 - Create the run-time image
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html