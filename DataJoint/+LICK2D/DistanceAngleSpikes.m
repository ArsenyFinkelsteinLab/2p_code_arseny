%{
# 
-> EXP2.SessionEpoch
vn_mises_correlation_treshold       : double   #
column_radius                       : double #
---
theta_lateral_distance              : blob   #
theta_lateral_distance_shuffled     : blob   #
bins_lateral_distance               : blob   #

theta_axial_distance                : blob   #
theta_axial_distance_shuffled       : blob   #
bins_axial_distance                 : blob   #
%}


classdef DistanceAngleSpikes < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch  & IMG.Mesoscope &  LICK2D.ROILick2DangleSpikes;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            flag_spikes = 1; % 1 spikes, 0 dff
            VM_threshold_vector = [0.5, 0.75];
            column_radius_vector = [20, 30, 40, 50];
            
            rel_temp = IMG.Volumetric & key;
            if rel_temp.count ==0
                column_radius_vector=0;
            end
            
            for i_th = 1:1:numel(VM_threshold_vector)
                for i_c = 1:1:numel(column_radius_vector)
                    key=Lick2D_DistanceAngle(key, flag_spikes, VM_threshold_vector(i_th), column_radius_vector(i_c));
                                insert(self,key);
                end
            end
        end
    end
end