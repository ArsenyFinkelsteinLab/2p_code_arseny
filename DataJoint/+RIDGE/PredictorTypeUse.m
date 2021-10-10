%{
#
predictor_name         : varchar(200)                  #
---
%}


classdef PredictorTypeUse < dj.Lookup
    properties
        contents = {
            
        
%         'LickPortBlockStart'
%         
%         'RewardSize'
%         
%         'Lick'
%         'RewardDelivery'
%         'RewardOmission'
%         
%         'PawFrontLeft'
%         'PawFrontRight'
%         'Whiskers'
%         'Jaw'

        
        
          'LickPort_pos_x' 
            'LickPort_pos_z'   
        
%          'LickPortEntrance'   
%             'LickPortExit'      
%             'LickPortBlockStart' 
% 
%             'AutoWater'          
%             'RewardDelivery'     
            'RewardSize'         
%             'RewardOmission'    
% 
            'Lick'               
            'LickTouch'           
%             'LickNoTouch'        
%             'LickTouchReward'    
%             'LickTouchNoReward'  
%             'LickTouchNoRewardOmitted'  
% 
            'FirstLickTouch'    
            'FirstLickReward'   
%             'PawFrontLeft'       
%             'PawFrontRight'      
            'Whiskers'           
            'Nose'               
            'Jaw'               

        
        











            };
    end
end

