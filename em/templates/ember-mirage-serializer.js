import DS from 'ember-data';

export default DS.JSONAPISerializer.extend({
  serializeHasMany(snapshot, json, relationship){
    let isArr = (snapshot.hasMany(relationship.key).length > 1) ? true : false;
    if(!json['relationships']){ 
      json['relationships'] = {};
    }
    json['relationships'][relationship.type] = snapshot.hasMany(relationship.key).reduce((obj, item) => {
      if(isArr){ 
        obj.data.push({id: item.id, type: item.modelName});
      }else{
        obj.data = {id: item.id, type: item.modelName};
      }
      return obj;
    }, isArr ? {data: []} : {data: null});
    return json;
  }
});
