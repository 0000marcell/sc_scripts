import Ember from 'ember';

export default Ember.Route.extend({
	model(){
		return this.store.createRecord('user');
	},
	session: Ember.inject.service('session'),
	actions: {
		login(model, view){
			view.set('logging', true);
			this.get('session').authenticate('authenticator:oauth2', 
				model.get('email'), 
				model.get('password')).then(() => {
				let username = this.get('session.data.authenticated.user.username');
				this.store.find('user', username).then((user) => {
					this.transitionTo('users.user', user);
				});
			}, (errors) => {
				view.set('logging', false);
				view.set('errors', errors.errors.title);
			});
		}
	}
});
