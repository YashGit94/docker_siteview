# FROM node:lts-alpine AS BUILD
# WORKDIR /app

# # 1. Copy and install dependencies first for layer caching
# COPY package*.json ./
# RUN npm install --silent

# # 2. Copy all application source code
# COPY . .

# # 3. Build the Angular application for production
# # This uses the correct ng build command structure to create the 'dist' folder.
# RUN npm run build -- --configuration=production --base-href=/

# # --- Stage 2: Production Stage (Uses a tiny Nginx image to serve static files) ---
# FROM nginx:alpine

# # 4. CRITICAL: Copy the built files from the 'BUILD' stage to Nginx's web root
# # CHANGED: Trying the slightly deeper 'browser' directory, which is common in Angular builds.
# # If this fails, we will try the original path again, but with a slight change (next step).
# COPY --from=BUILD /app/dist/sitenov/browser /usr/share/nginx/html

# # Nginx runs on port 80 by default
# EXPOSE 80

# # Command to run Nginx when the container starts
# CMD ["nginx", "-g", "daemon off;"]


# --- Stage 1: Build Stage ---
# Use the LTS version of Node on Alpine for a lightweight build environment
FROM node:lts-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package files first to leverage Docker layer caching for dependencies
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the Angular application for production
# This command generates the static files in the dist/sitenov directory
RUN npm run build -- --configuration=production

# --- Stage 2: Serve Stage ---
# Use a lightweight Nginx server to host the built application
FROM nginx:alpine

# Copy the build artifacts from the previous stage to Nginx's public directory
# Based on your angular.json, the output path is dist/sitenov
COPY --from=build /app/dist/sitenov /usr/share/nginx/html

# Expose port 80 to access the application locally
EXPOSE 80

# Command to start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
