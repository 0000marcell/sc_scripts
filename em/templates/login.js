import Ember from 'ember';

export default Ember.Route.extend({
  actions: {
    transition(model){
      this.transitionTo('users.user', model);  
    }
  }
});
