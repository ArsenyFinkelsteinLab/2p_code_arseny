%{
# Positional 2D tuning of a neuron (firing-rate map averaged across the entire trial duration) with each pixel corresponding to neuronal response to a specific lick-port position in 2D
-> EXP2.SessionEpoch
-> IMG.ROI
number_of_bins                          : int   #
---
lickmap_fr_regular                      : blob   # 2D tuning map averaged across trials with typical reward
lickmap_fr_small=null                   : blob   # 2D tuning map averaged across no rewarded trials
lickmap_fr_large=null                   : blob   # 2D tuning map averaged across trials with large reward
lickmap_fr_first=null                   : blob   # 2D tuning map averaged across first trial in block
lickmap_fr_begin=null                   : blob   # 2D tuning map averaged across trials in the beginning of the block
lickmap_fr_mid=null                     : blob   # 2D tuning map averaged across trials in the middle of the block
lickmap_fr_end=null                     : blob   # 2D tuning map averaged across trials in the end of the block
lickmap_fr_regular_odd                  : blob   # 2D tuning map averaged across trials with typical reward  -- only odd trials
lickmap_fr_regular_even                 : blob   # 2D tuning map averaged across trials with typical reward  -- only even trials
pos_x_bins_centers                      : blob   # binning used for the 2D tuning maps
pos_z_bins_centers                      : blob   # binning used for the 2D tuning maps
%}


classdef ROILick2DmapSpikesExample < dj.Computed
    properties
        keySource = EXP2.Session & IMG.ROIExample;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            % % also populates
            self2=LICK2D.ROILick2DmapPSTHSpikesExample;
            self3=LICK2D.ROILick2DmapPSTHStabilitySpikesExample;
            
            k1 = fetch(LICK2D.ROILick2DmapSpikes & IMG.ROIExample & key,'*');
            insert(self,k1);
            
            k2 = fetch(LICK2D.ROILick2DmapPSTHSpikes & IMG.ROIExample & key,'*');
            insert(self2,k2);
            
            k3 = fetch(LICK2D.ROILick2DmapPSTHStabilitySpikes & IMG.ROIExample & key,'*');
            insert(self3,k3);
        end
    end
end