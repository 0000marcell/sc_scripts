import Ember from 'ember';

export default Ember.Controller.extend({
	msgProp: {},
	actions: {
		signup(){
			var user = this.get('model');
			user.save().then(() => {
				this.set('msgProp.msg', 'Confirmation message sent, check your email!');
			}).catch((resp) => {
				this.set('msgProp.msg', 'error: '+resp);
			});
		}
	}
});
