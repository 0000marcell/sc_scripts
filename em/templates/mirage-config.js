import Mirage from 'ember-cli-mirage';

export default function() {
	this.namespace = '/api/v1';
	this.post('/login', (schema, request) => {
		let requestBody = request.requestBody,
				email;
		if(/username=/.test(requestBody)){
			email = 
			decodeURIComponent(requestBody
				.split('username=')[1].split('&')[0]);
		}else{
			return;	
		}
		let user = schema.users.where({ 
			email: email
		}).models[0];
		if(user){
			return  {"access_token":
				"43de36e1a9266aea606265b524b82578963b9b9efdbef7e2ed003a6bb7185a4b",
				"token_type":"bearer",
				"expires_in": 7200,
				"created_at": 1466035645,
				"user": user};
		}else{
			return new Mirage.Response(422, 
				{type: 'header'}, 
				{errors: {title: ['Wrong email/password combination']}});
		}
	});
	this.post('/users');
  this.get('/users', (schema, request) => {
    if(request.queryParams.username){
      return schema.users.where({
        username: request.queryParams.username
      }).models[0];
    }else{
      return schema.users.all();  
    }
  });
	this.get('/users/:id');
	this.patch('/users/:id');
}
