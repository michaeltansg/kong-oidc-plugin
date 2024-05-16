# Use the official Kong image as a base - kong:alpine does not have ARM arch image
FROM kong:latest

# Ensure any patching steps are executed as root user
USER root

# Add custom plugin to the image
COPY plugins/oidc /usr/local/share/lua/5.1/kong/plugins/oidc
RUN luarocks install lua-resty-openidc 1.7.6-3

# FOR DEBUGGING
COPY kong.conf /etc/kong/

# Set environment variables to ensure Kong detects the custom plugin
ENV KONG_PLUGINS="bundled,oidc"
ENV KONG_LUA_PACKAGE_PATH="/usr/local/share/lua/5.1/kong/plugins/?.lua;;"
ENV KONG_SESSION_SECRET: my_kong_session_secret

# Ensure kong user is selected for image execution
USER kong