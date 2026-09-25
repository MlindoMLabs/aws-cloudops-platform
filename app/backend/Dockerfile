# Build / Execution Stage
FROM node:20-alpine AS base

# Set working directory
WORKDIR /usr/src/app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy application source code
COPY . .

# Environment variables defaults
ENV PORT=5000 \
    NODE_ENV=production

# Expose backend service port
EXPOSE 5000

# Security best practice: Run as non-root user
USER node

# Health check probe
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:5000/live || exit 1

# Container start command
CMD ["node", "src/app.js"]
