# How to use the Makefile
`make start`: builds Kong with custom OIDC plugin baked into the image, then runs the docker compose command.
`make restart` : use after modifying plugin file and then restart kong to pick up the changes made without rebuilding a new image.
`make renew` : this destroys the kong container, rebuilds the kong oidc image and start kong

Alternatively, you can use `fswatch` to observe for changes in plugin directory and restart the Kong service:
```bash
brew install fswatch
fswatch -o ./plugins | xargs -n1 -I{} make restart &
```

To terminate a watch:
```bash
kill -9 $(ps aux | grep '[f]swatch' | awk '{print $2}')
```

## Setup Kong default services and routes for Open WebUI

To setup default service and routes: `sh 1.kong-openwebui-setup.sh`
[Optional] To add additional request transformer plugin: `sh 2.kong-openwebui-request-txformer.sh`

## Configure the OIDC Plugin

   - **Enable the OIDC Plugin** on the service or route where authentication is required.
   - **Plugin Configuration**: You need to configure the plugin with your Azure AD details:
     - `client_id`: The Application ID from Azure AD.
     - `client_secret`: The client secret you created.
     - `discovery`: The .well-known configuration URL of Azure AD (usually `https://login.microsoftonline.com/{tenant_id}/.well-known/openid-configuration`).
     - `scope`: openid email profile
     - `redirect_uri`: The redirect URI
     - `session_secret`: Unsure if this is required at the moment.

**Configure Redirect URIs**: Ensure that the redirect URIs in both Azure AD and the Kong configuration align properly.

## Test the Integration

1. **Access the Application**: Try accessing the application through the Kong-managed route.
2. **Login Flow**: You should be redirected to the Azure AD login page. After successful authentication, Azure AD will redirect back to your application through Kong.

3. **Verify Secure Access**: Ensure that only authenticated users are able to access the application.

Reference documents: 
https://github.com/nokia/kong-oidc/blob/master/docs/kong_oidc_flow.png
https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc
https://docs.konghq.com/gateway/3.6.x/reference/nginx-directives/
https://docs.konghq.com/gateway/3.6.x/reference/configuration/#nginx_user
https://docs.konghq.com/gateway/3.6.x/reference/configuration/#nginx-injected-directives-section