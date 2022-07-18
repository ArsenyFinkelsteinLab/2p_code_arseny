%{ 
# Correction based on ETL callibration
plane_depth              : double           # imaging plane depth in um
---
etl_affine_transform=null   : blob      #  affine transform to correct for ETL abberations,computed based on ETL callibration with pollen grains
%}


classdef ETLTransform < dj.Lookup
    methods(Access=protected)
        function makeTuples(self, key)
            
        % To populate run this function: train_affine_transform_ETL()
        % To test the quality of the transform run this function test_affine_transform_ETL() functions

        
        end
    end
end