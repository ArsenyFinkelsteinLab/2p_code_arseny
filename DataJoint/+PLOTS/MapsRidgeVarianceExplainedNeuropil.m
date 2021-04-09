%{
#
-> EXP2.Session
---
%}


classdef MapsRidgeVarianceExplainedNeuropil < dj.Computed
    properties
        keySource = EXP2.Session &  RIDGE.ROIRidgeVarExplainedNeuropil;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\ridge_variance_explained_neuropil\'];
            rel_data=RIDGE.ROIRidgeVarExplainedNeuropil;
            PLOTS_MapsRidgeVarianceExplained(key, dir_current_fig, rel_data);
            insert(self,key);
            
        end
    end
end