function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'PLOTS', 'arseny_learning_plots');
end
obj = schemaObject;
end
