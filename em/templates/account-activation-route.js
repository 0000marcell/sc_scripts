import Ember from 'ember';

export default Ember.Route.extend({
  model(param){
    return {email: param.email, token: param.token};
  }
});

