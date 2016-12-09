import Ember from 'ember';

export default Ember.Controller.extend({
  msgProp: {},
  authManager: Ember.inject.service('session'),
  actions: {
    login(){
      this.get('authManager').authenticate('authenticator:oauth2', 
        this.get('email'), 
        this.get('password')).then(() => {
          var user = this.store.find('user', this.get('authManager.data.authenticated.user.id'));
          this.transitionToRoute('users.user', user);
        }, () => {
        this.set('msgProp.msg', 'wrong email/password combination!');
      });
    }
  }
});
