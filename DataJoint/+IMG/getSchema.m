function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'IMG', 'arseny_learning_imaging');
end
obj = schemaObject;
end
