# Use this image as the platform to build the app
FROM node:18-alpine AS external-website
ENV ELASTICSEARCH_URL=https://localhost:9200
ENV ORIGIN=localhost:3000
# The WORKDIR instruction sets the working directory for everything that will happen next
WORKDIR /app

# Copy all local files into the image
COPY . .

# Clean install all node modules
RUN npm i

# Build SvelteKit app
RUN ls -al
RUN npm run build

# Delete source code files that were used to build the app that are no longer needed
RUN rm -rf src/ static/ docker-compose.yml
RUN ls -al

# The USER instruction sets the user name to use as the default user for the remainder of the current stage
USER node:node

# This is the command that will be run inside the image when you tell Docker to start the container
CMD ["node","build/index.js"]