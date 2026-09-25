# Stage 1: Build the React application with Vite
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci

COPY . .

# Build production static assets (dist folder)
RUN npm run build

# Stage 2: Serve static files with Nginx
FROM nginx:alpine

# Copy built assets from builder stage to Nginx web root
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html

# Copy custom Nginx proxy configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose Nginx HTTP port
EXPOSE 80

# Health check probe
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
