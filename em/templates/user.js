import Ember from 'ember';
import ApplicationRouteMixin from 'ember-simple-auth/mixins/application-route-mixin';
import AuthenticatedRouteMixin from 'ember-simple-auth/mixins/authenticated-route-mixin';

export default Ember.Route.extend(ApplicationRouteMixin, AuthenticatedRouteMixin, {
  session: Ember.inject.service(),
	model(param){
    return this.store.queryRecord('user', {username: param.user_username});
	},
	actions: {
		logout(){
			this.get('session').invalidate();	
		}
	}
});
