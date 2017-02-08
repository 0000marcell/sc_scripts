import { camelize, singularize, pluralize } from 'ember-cli-mirage/utils/inflector';
import assert from 'ember-cli-mirage/assert';

export default {
  put(schema, request){
    let json      = JSON.parse(request.requestBody),
        model     = (json.data.id) ? 
                    schema[camelize(json.data.type)].find(json.data.id) : 
                    schema[camelize(json.data.type)].create(),
        id        = model.id,
        modelType = singularize(json.data.type);

    assert(
      json.data && (json.data.attributes || json.data.type || json.data.relationships),
      `You're using a shorthand or #normalizedRequestAttrs, but your serializer's normalize function did not return a valid JSON:API document. http://www.ember-cli-mirage.com/docs/v0.2.x/serializers/#normalizejson`
    );

    let attrs = {};
    if (json.data.attributes) {
      attrs = Object.keys(json.data.attributes).reduce((sum, key) => {
        sum[camelize(key)] = json.data.attributes[key];
        return sum;
      }, {});
    }

    model.update(attrs);

    if (json.data.relationships) {
      Object.keys(json.data.relationships).forEach((key) => {
        let relationship = json.data.relationships[key],
            camelizedKey,
            joinModel;
        if(modelType > key){
          joinModel = camelize(pluralize(`${modelType}-${key}`));
        }else{
          joinModel = camelize(pluralize(`${key}-${modelType}`));
        }
        if(schema[joinModel]){
          let newItem = {}; 
          if(!Array.isArray(relationship.data)){
            newItem[`${modelType}Id`] = id;
            newItem[`${key}Id`] = relationship.data.id;
            schema[joinModel].create(newItem);
          }else{
            relationship.data.map((obj) => {
              newItem = {};
              newItem[`${modelType}Id`] = id;
              newItem[`${key}Id`] = obj.id;
              schema[joinModel].create(newItem);
            });
          }
        }else{
          if (!Array.isArray(relationship.data)) {
            camelizedKey = `${singularize(camelize(key))}Id`;
            attrs[camelizedKey] = relationship.data && relationship.data.id;
          }else{
            camelizedKey = `${singularize(camelize(key))}Ids`;
            attrs[camelizedKey] = [];
            relationship.data.map(function(obj){
              attrs[camelizedKey].push(obj.id);
            });
          }
          model[camelizedKey] = attrs[camelizedKey];
        }
      }, {});
    }
    model.save();
    return model;
  },
};
