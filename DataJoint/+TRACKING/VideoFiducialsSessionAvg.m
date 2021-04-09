%{
#
-> EXP2.Session
-> TRACKING.VideoFiducialsType
---
fiduical_x_median_session=null     : double  #  fiducial coordinate along, averaged across all trials for the entire session
fiduical_y_median_session=null     : double 
fiduical_x_min_session=null     : double
fiduical_y_min_session=null     : double
fiduical_x_max_session=null     : double
fiduical_y_max_session=null     : double
%}



classdef VideoFiducialsSessionAvg < dj.Imported
    properties
        keySource = (EXP2.Session  & TRACKING.TrackingTrial & TRACKING.VideoFiducialsTrial)* TRACKING.VideoFiducialsType
    end
    methods(Access=protected)
        
        function makeTuples(self, key)
            key.fiduical_x_median_session =nanmedian(fetchn(TRACKING.VideoFiducialsTrial & key,'fiduical_x_median'));
            key.fiduical_y_median_session =nanmedian(fetchn(TRACKING.VideoFiducialsTrial & key,'fiduical_y_median'));
            
            key.fiduical_x_min_session =prctile(fetchn(TRACKING.VideoFiducialsTrial & key,'fiduical_x_min'),10);
            key.fiduical_y_min_session =prctile(fetchn(TRACKING.VideoFiducialsTrial & key,'fiduical_y_min'),10);

            key.fiduical_x_max_session =prctile(fetchn(TRACKING.VideoFiducialsTrial & key,'fiduical_x_max'),90);
            key.fiduical_y_max_session =prctile(fetchn(TRACKING.VideoFiducialsTrial & key,'fiduical_y_max'),90);

            insert(self,key)
        end
        
    end
end

