function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'EXP2', 'arseny_s1alm_experiment2');
end
obj = schemaObject;
end
