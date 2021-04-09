%{
# include good ROI that were considered cell by suite2p
-> IMG.ROI
%}


classdef ROIGood < dj.Imported
    properties
        keySource = IMG.Plane;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            local_path_plane_registered = fetchn(IMG.PlaneDirectory & key,'local_path_plane_registered');
            if isempty(local_path_plane_registered)==0 %for newer code
                iscell=readNPY([local_path_plane_registered{1} 'iscell.npy']);
            else %for older code
                dir_data2 = fetchn(EXP2.SessionEpochDirectory &key,'local_path_session_registered');
                dir_data2 = dir_data2{1};
                iscell=readNPY([dir_data2 '\suite2p\plane0\iscell.npy']);
            end
            iscell=logical(iscell(:,1));
            R=fetch(IMG.ROI & key,'ORDER BY roi_number');
            R=R(iscell);
            insert(self, R);
        end
    end
end