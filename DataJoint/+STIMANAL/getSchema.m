function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'STIMANAL', 'arseny_learning_photostim_anal');
end
obj = schemaObject;
end
