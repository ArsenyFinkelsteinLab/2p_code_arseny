function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'STIM', 'arseny_learning_photostim');
end
obj = schemaObject;
end
