import Ember from 'ember';
import ENV from "frontend/config/environment";

export default Ember.Component.extend({
  didInsertElement(){
    let model = this.get('model');
    let activationURL = 
      `${ENV.APP.host}/account_activations/${model.token}/edit?email=${encodeURIComponent(model.email)}`;
    debugger;
    Ember.$.ajax({
      type: "GET",
      url: activationURL,
    }).done(() => {
      this.set('loading', false);
      this.set('msgs', 
        'Your user was activated you can login now!');
    }).fail((error) => {
      this.set('loading', false);
      this.set('msgs',
          `An error occurred error: ${JSON.stringify(error)}`);
    });
  }
});
