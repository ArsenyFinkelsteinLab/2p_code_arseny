%{
#
predictor_name         : varchar(200)                  #
---
%}


classdef PredictorTypeUse < dj.Lookup
    properties
        contents = {
            
            'LickPortBlockStart' 

            'RewardSize'  
            
            'Lick'       
            'RewardDelivery'       
            'RewardOmission'    

            'PawFrontLeft'      
            'PawFrontRight'      
            'Whiskers'           
            'Jaw'              
            };
    end
end

