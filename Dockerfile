FROM nginx:alpine

# Set the correct directory Nginx serves from
WORKDIR /usr/share/nginx/html

# Clean any default Nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy all site content to the web root
COPY . /usr/share/nginx/html


RUN chown -R nginx:nginx /usr/share/nginx/html
# Expose port 80 for web traffic
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
