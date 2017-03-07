import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  model: {name: null, email: null, username: null, password: null, 
    passwordConfirmation: null},
  actions: {
    submit(view){
      let model = this.get('model');
      view.set('loading', true);
      this.get('store').createRecord('user', model).save()
        .then(() => {
				view.set('loading', false);
				view.get('msgs')
				  .pushObject('User created, check your email to register the user');
			}).catch((errors) => {
				view.set('loading', false);
        view.get('errors')
				  .pushObject(errors.errors);
			});
    }
  }
});
