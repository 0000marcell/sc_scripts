import { JSONAPISerializer } from 'ember-cli-mirage';
import { camelize, singularize, pluralize } from 'ember-cli-mirage/utils/inflector';

export default JSONAPISerializer.extend({
  serialize(){
    let json = JSONAPISerializer.prototype.serialize.apply(this, arguments);
    if (Array.isArray(json.data)) {
      json.data.forEach((data, i) => {
        this.serializeJoinModel(data, json, i);
      });
    }else{
      this.serializeJoinModel(json.data, json);
    }
    return json;
  },
  serializeJoinModel(data, json, i) {
    let modelType = singularize(data.type);
    for(let key in data.relationships){
      let joinModel = (data.type > key) ? 
                      camelize(pluralize(`${modelType}-${key}`)) :
                      camelize(pluralize(`${key}-${modelType}`));
      if(this.registry.schema[joinModel]){
        if (i || i === 0) {
          json.data[i].relationships[key].data = this.findJoinModel(data, joinModel, key);
        }else{
          json.data.relationships[key].data = this.findJoinModel(data, joinModel, key);
        }
      }
    }
  },
  findJoinModel(data, joinModel, key){
    let prop = singularize(key);
    return data.relationships[key].data.map(model => ({
      id: this.registry.schema[joinModel].find(model.id)[`${prop}Id`],
      type: prop,
    }));
  }
});
