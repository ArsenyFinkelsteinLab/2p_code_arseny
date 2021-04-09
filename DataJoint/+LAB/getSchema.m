function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'LAB', 'map_lab'); 
end
obj = schemaObject;
end
