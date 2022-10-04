%{
#
-> EXP2.SessionEpoch
---
temporal_component_autocorr_tau: blob  # the time constant of the auto correlaiton of the temporal component of the SVD, a vector of taus for each component
num_components        : int            # number of components analyzed, is limited to 1000
%}

classdef SVDTemporalComponentsAutocorr < dj.Computed
    
    properties
        keySource =(EXP2.SessionEpoch) & (POP.SVDTemporalComponents & 'time_bin=1.5') - IMG.Mesoscope;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            %             figure
            
            time_bin=[1.5];
            threshold_for_event=[0];
            frame_rate= fetchn(IMG.FOVEpoch &key,'imaging_frame_rate_volume');
            if isempty(frame_rate)
               frame_rate= fetchn(IMG.FOV &key,'imaging_frame_rate');
            end
            k.threshold_for_event=threshold_for_event;
            temporal_component =cell2mat(fetchn(POP.SVDTemporalComponents &  k & key & sprintf('time_bin<%.2f AND time_bin>%.2f',time_bin*1.1,time_bin*0.9),'temporal_component', 'ORDER BY component_id'));
            
             for i_c=1:1:size(temporal_component,1)
                [AC,lags] = xcorr(temporal_component(i_c,:));
                AC = AC(lags>0);
                lags = lags(lags>0);
                
                %                 plot(lags/frame_rate,AC)
                %                 xlabel('Lag (s)')
                
                tau(i_c)=find(AC<0,1,'first')/frame_rate; %autocorrelation time constant
                
                
            end
            
            key.num_components=size(temporal_component,1);
            key.temporal_component_autocorr_tau=tau;
            insert(self,key);
            
            
        end
    end
end
