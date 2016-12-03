import Ember from 'ember';

export default Ember.Route.extend({
	model(){
		return this.store.createRecord('user');
	},
	actions: {
		signup(user, view){
			view.set('signingup', true);
			user.save().then(() => {
				view.set('signingup', false);
				view.get('msgs')
				.pushObject('Confirmation message sent, check your email!');
			}).catch((errors) => {
				view.set('signingup', false);
				view.get('errors')
				.pushObject(errors);
			});
		}
	}
});
