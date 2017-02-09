import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    submit(model, view){
      view.set('loading', true);
      model.save().then(() => {
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
