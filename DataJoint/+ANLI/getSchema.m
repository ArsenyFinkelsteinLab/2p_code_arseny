function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'ANLI', 'arseny_learning_analysis');
end
obj = schemaObject;
end
