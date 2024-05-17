# Use the official Kong image as a base - kong:alpine does not have ARM arch image
FROM kong:latest

# Ensure any patching steps are executed as root user
USER root

# Add custom plugin to the image
COPY plugins/oidc /usr/local/share/lua/5.1/kong/plugins/oidc
RUN luarocks install lua-resty-openidc 1.7.6-3
# There are bug in lua-resty-session
# https://github.com/zmartzone/lua-resty-openidc/pull/489#issuecomment-1761716455
RUN luarocks remove lua-resty-session 4.0.5-1 --force

# Set environment variables to ensure Kong detects the custom plugin
ENV KONG_PLUGINS="bundled,oidc"
ENV KONG_LUA_PACKAGE_PATH="/usr/local/share/lua/5.1/kong/plugins/?.lua;;"

# Ensure kong user is selected for image execution
USER kong