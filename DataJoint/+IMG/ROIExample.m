%{
# include ROI to display in publication figures as example cells
-> IMG.ROI
%}


classdef ROIExample < dj.Imported
    properties
        keySource = LAB.Subject & 'subject_id=480483';
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            
            %             uids  = [62450, 70899, 73685, 74265];
            uids  = [1303968
                1303443
                1303933
                1303344
                1303338
                1304833
                1303965
                1302797
                1302433
                1303442
                1303531
                1302587
                1303336
                1302649
                1303290
                1304851
                1304681
                1303316
                1305030
                1303463];
            
            for i = 1:1:numel(uids)
                k.roi_number_uid = uids(i);
                r = fetch(IMG.ROI & k);
                insert(self,r);
            end
            
        end
    end
end