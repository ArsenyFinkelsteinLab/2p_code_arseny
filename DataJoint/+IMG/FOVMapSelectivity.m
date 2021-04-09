%{
# Field of View
-> IMG.FOV
-> EXP2.Outcome
-> EXP2.EpochName2

---
map_selectivity_f           : longblob      # trial-averaged map of selectivity (R-L), flourescence for different trial epochs
map_selectivity_dff         : longblob      #  median activity of each pixel at presample period

%}


classdef FOVMapSelectivity < dj.Imported
    properties
        keySource = (IMG.FOV & IMG.FOVMapActivity) * EXP2.EpochName2 * (EXP2.Outcome & 'outcome="hit"');
    end
    methods(Access=protected)
        function makeTuples(self, key)
            k=key;
            
            k.trial_type_name='l';
            f_L=fetch1(IMG.FOVMapActivity & k, 'map_activity_f');
            dff_L=fetch1(IMG.FOVMapActivity & k, 'map_activity_dff');

            k.trial_type_name='r';
            f_R=fetch1(IMG.FOVMapActivity & k, 'map_activity_f');
            dff_R=fetch1(IMG.FOVMapActivity & k, 'map_activity_dff');
            
            key.map_selectivity_f = f_R - f_L;
            key.map_selectivity_dff = dff_R - dff_L;
            
            insert(self,key);
            
        end
    end
end