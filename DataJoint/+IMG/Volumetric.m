%{
# Field of View
-> EXP2.Session
%}


classdef Volumetric < dj.Imported
    properties
        keySource = EXP2.Session;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            rel= (IMG.Plane & 'plane_num>1' & key);
            if rel.count>0
            insert(self,key)
            end
        end
    end
end