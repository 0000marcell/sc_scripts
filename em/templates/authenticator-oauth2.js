// Used to authenticate the user on the backend
import OAuth2PasswordGrant from 'ember-simple-auth/authenticators/oauth2-password-grant';
// name of the app to import the env
import ENV from 'ember-test/config/environment';

export default OAuth2PasswordGrant.extend({
	serverTokenEndpoint: `${ENV.endPoint}/oauth/token`
});
