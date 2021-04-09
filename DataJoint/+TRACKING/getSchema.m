function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'TRACKING', 'arseny_learning_tracking');
end
obj = schemaObject;
end
