function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'LICK2D', 'arseny_learning_lick2d');
end
obj = schemaObject;
end
