%{
#
-> EXP2.Session
---
%}


classdef MapsRidgeNeuropil < dj.Computed
    properties
        
        keySource = EXP2.Session &  RIDGE.ROIRidge;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\lick2D\ridge_neuropil\'];
            rel_data=RIDGE.ROIRidgeNeuropil & IMG.ROIGood;
            predictor_name=fetchn(RIDGE.PredictorType& RIDGE.PredictorTypeUse,'predictor_name','ORDER BY predictor_name');
            threshold=[0];
            time_shift_vec=[-2:1:7];
            
            
            rel_all = IMG.ROI*IMG.PlaneCoordinates & key & rel_data;
            M=fetch(rel_all ,'*');
            
            
            
            for ii = 1:1:numel(threshold)
                key.threshold_for_flourescence_event=threshold(ii);
                for jj=1:1:numel(predictor_name)
                    key.predictor_name = predictor_name{jj};
                    
                    for tt=1:1:numel(time_shift_vec)
                        key.time_shift=time_shift_vec(tt);
                        R(:,tt) = fetchn(rel_data & key,'predictor_beta','ORDER BY roi_number');
                    end
                    
                    upper=prctile(R(:),99);
                    lower=prctile(R(:),1);
                    bounds = max([abs(lower), abs(upper)]);
                    
                    parfor tt=1:1:numel(time_shift_vec)
                        PLOTS_MapsRidge(key, dir_current_fig, rel_data,tt, bounds, M, R(:,tt), time_shift_vec(tt));
                    end
                end
            end
            %             end
            
            key=rmfield(key,'threshold_for_flourescence_event');
            key=rmfield(key,'predictor_name');
            key=rmfield(key,'time_shift');
            
            insert(self,key);
            
        end
    end
end