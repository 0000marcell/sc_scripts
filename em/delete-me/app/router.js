import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('home', function() {
    this.route('login');
    this.route('signup');
  });

  this.route('users', {
    path: ':user_username'
  }, function() {
    this.route('user', {
      path: ':user_username'
    });
  });
});

export default Router;
