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


# ... existing build stages ...

# Change 'AS BUILD' to lowercase 'as build'
FROM node:lts-alpine AS build
WORKDIR /app

# 1. Copy and install dependencies
COPY package*.json ./
RUN npm install --silent

# 2. Copy all application source code
COPY . .

# 3. Build the Angular application
RUN npm run build -- --configuration=production --base-href=/

# --- Stage 2: Production Stage ---
FROM nginx:alpine

# Change Nginx default port to 8080 for App Engine Flexible compliance
RUN sed -i 's/listen  80;/listen 8080;/g' /etc/nginx/conf.d/default.conf

# 4. Copy built files using the lowercase alias 'build'
# Based on your angular.json, the output is 'dist/sitenov'
COPY --from=build /app/dist/sitenov /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
