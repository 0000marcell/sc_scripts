import Ember from 'ember';

export default Ember.Component.extend({
  session: Ember.inject.service(),
  cableService: Ember.inject.service('cable'),
  willDestroy(){
		this.get('consumer').subscriptions
			.remove(this.get('subscription'));
	},
  setupSubscription: Ember.on('didInsertElement', function(){
    let remember_token = 
      this.get('session.data.authenticated.remember_token');
		var consumer = this.get('cableService')
			.createConsumer(`ws://0.0.0.0:3000/websocket/${remember_token}`);
		this.set('consumer', consumer);
		var subscription = consumer.subscriptions
      .create("MessagesChannel", {
			received: (data) => {
        //handle the received data
			}
		});
		this.set('subscription', subscription);
	}),
  actions: {
    sendMessage(){
      this.get('subscription')
        .perform('#CALL A METHOD', { foo: 'iiiiiiii'  });
      this.get('subscription')
			  .send({ name: '#SEND DATA' });
    }
  }
});
