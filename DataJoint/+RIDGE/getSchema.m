function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'RIDGE', 'arseny_learning_ridge');
end
obj = schemaObject;
end
