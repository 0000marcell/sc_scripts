import ENV from 'ember-test/config/environment';
import DataAdapterMixin from 'ember-simple-auth/mixins/data-adapter-mixin';
import DS from 'ember-data';

export default DS.JSONAPIAdapter.extend(DataAdapterMixin, {
	host: ENV.endPoint,
	namespace: 'api/v1',
	authorizer: 'authorizer:oauth2',
	coalesceFindRequests: true,
	parseErrorResponse: function(responseText) {
		var response = JSON.parse(responseText);
	 	var json = {errors: [response]};
		return json;
	}

});
