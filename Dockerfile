# # # FROM node:lts-alpine AS BUILD
# # # WORKDIR /app

# # # # 1. Copy and install dependencies first for layer caching
# # # COPY package*.json ./
# # # RUN npm install --silent

# # # # 2. Copy all application source code
# # # COPY . .

# # # # 3. Build the Angular application for production
# # # # This uses the correct ng build command structure to create the 'dist' folder.
# # # RUN npm run build -- --configuration=production --base-href=/

# # # # --- Stage 2: Production Stage (Uses a tiny Nginx image to serve static files) ---
# # # FROM nginx:alpine

# # # # 4. CRITICAL: Copy the built files from the 'BUILD' stage to Nginx's web root
# # # # CHANGED: Trying the slightly deeper 'browser' directory, which is common in Angular builds.
# # # # If this fails, we will try the original path again, but with a slight change (next step).
# # # COPY --from=BUILD /app/dist/sitenov/browser /usr/share/nginx/html

# # # # Nginx runs on port 80 by default
# # # EXPOSE 80

# # # # Command to run Nginx when the container starts
# # # CMD ["nginx", "-g", "daemon off;"]


# # # # --- Stage 1: Build Stage ---
# # # # Use the LTS version of Node on Alpine for a lightweight build environment
# # # FROM node:lts-alpine AS build

# # # # Set the working directory inside the container
# # # WORKDIR /app

# # # # Copy package files first to leverage Docker layer caching for dependencies
# # # COPY package*.json ./

# # # # Install project dependencies
# # # RUN npm install

# # # # Copy the rest of the application source code
# # # COPY . .

# # # # Build the Angular application for production
# # # # This command generates the static files in the dist/sitenov directory
# # # RUN npm run build -- --configuration=production

# # # # --- Stage 2: Serve Stage ---
# # # # Use a lightweight Nginx server to host the built application
# # # FROM nginx:alpine

# # # # Copy the build artifacts from the previous stage to Nginx's public directory
# # # # Based on your angular.json, the output path is dist/sitenov
# # # COPY --from=build /app/dist/sitenov /usr/share/nginx/html

# # # # Expose port 80 to access the application locally
# # # EXPOSE 80

# # # # Command to start Nginx in the foreground
# # # CMD ["nginx", "-g", "daemon off;"]



# # ## variable wise trigger

# # # Stage 1: Build
# # FROM node:lts-alpine AS BUILD
# # WORKDIR /app

# # # Accept the build configuration as an argument (defaults to production)
# # ARG BUILD_CONFIG=production

# # COPY package*.json ./
# # RUN npm install --silent

# # COPY . .

# # # Use the variable in the build command
# # RUN npm run build -- --configuration=$BUILD_CONFIG --base-href=/

# # # --- Stage 2: Production Stage ---
# # FROM nginx:alpine

# # # 1. Remove default Nginx static assets
# # RUN rm -rf /usr/share/nginx/html/*

# # # 2. Copy the built Angular files from the 'BUILD' stage
# # # The 'browser' folder contents must go directly into 'html'
# # COPY --from=BUILD /app/dist/sitenov/browser /usr/share/nginx/html

# # # 3. Copy your custom nginx.conf to the Nginx configuration directory
# # # This file must exist in your root directory next to the Dockerfile
# # COPY nginx.conf /etc/nginx/conf.d/default.conf

# # # 4. Handle the dynamic $PORT provided by Cloud Run
# # CMD ["sh", "-c", "sed -i 's/listen.*80;/listen '\"$PORT\"';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]


# #previous
# # --- Stage 1: Build ---
# FROM node:lts-alpine AS BUILD
# WORKDIR /app
# COPY package*.json ./
# RUN npm install --silent
# COPY . .
# RUN npm run build -- --configuration=production --base-href=/

# # Stage 2: Production
# FROM nginx:alpine

# # Remove default nginx static assets
# RUN rm -rf /usr/share/nginx/html/*

# # Ensure you copy the CONTENTS of the browser folder, not the folder itself
# COPY --from=BUILD /app/dist/sitenov/browser /usr/share/nginx/html
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# # # Copy build output from 'BUILD' stage to nginx html folder
# # # NOTE: Ensure this path matches your Angular output (dist/sitenov/browser)
# # COPY --from=BUILD /app/dist/sitenov/browser /usr/share/nginx/html

# # # Copy your custom nginx.conf to replace the default
# # COPY nginx.conf /etc/nginx/conf.d/default.conf

# # Dynamic port handling for Cloud Run
# CMD ["sh", "-c", "sed -i 's/listen.*80;/listen '\"$PORT\"';/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]


FROM nginx:alpine

# 1. Force Nginx to use port 8080 (Cloud Run default)
RUN sed -i 's/listen  80;/listen 8080;/g' /etc/nginx/conf.d/default.conf

# 2. Clear out the default Nginx welcome files
RUN rm -rf /usr/share/nginx/html/*

# 3. COPY THE CONTENT FROM SRC DIRECTLY INTO THE HTML ROOT
# This moves index.html from 'src/' to the location Nginx expects
COPY ./src/ /usr/share/nginx/html/

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
