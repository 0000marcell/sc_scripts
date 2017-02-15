import Ember from 'ember';

export default Ember.Component.extend({
	init(){
		this._super(...arguments);		
		this.set('errors', []);
		this.set('msgs', []);
		this.set('loading', false);
	},
	actions: {
		save(){
			this.get('submit')(this);	
		}
	}
});
