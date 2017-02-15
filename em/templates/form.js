import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  model: {<props>},
  actions: {
    submit(view){
      let model = this.get('model');
      view.set('loading', true);
      this.get('store').createRecord('<user-model>', model).save()
        .then(() => {
				view.set('loading', false);
				view.get('msgs')
				  .pushObject('Created!');
			}).catch((errors) => {
				view.set('loading', false);
        view.get('errors')
				  .pushObject(errors.errors);
			});
    }
  }
});
