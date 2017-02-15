import Ember from 'ember';

export default Ember.Component.extend({
  user: {email: null, password: null},
  session: Ember.inject.service('session'),
  actions: {
		login(view){
      let user = this.get('user');
			view.set('logging', true);
			this.get('session').authenticate('authenticator:oauth2', 
				user.email, 
				user.password).then(() => {
        this.get('transition')(this.get('session.data.authenticated.user.username'));
			}, (errors) => {
				view.set('logging', false);
				view.set('errors', errors.errors.title);
			});
		}
	}
});
