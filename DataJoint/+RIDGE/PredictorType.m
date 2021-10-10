%{
#
predictor_name         : varchar(200)                  #
---
predictor_category     : varchar(1000)                 #
predictor_description  : varchar(1000)                 #
%}


classdef PredictorType < dj.Lookup
    properties
        contents = {
            
            'LickPort_pos_x'   'task' 'lickport pos_x from zaber motor'
            'LickPort_pos_z'   'task' 'lickport pos_z from zaber motor'

        
            'LickPortEntrance'   'task' 'lickport entrance'
            'LickPortExit'       'task' 'lickport exit'
            'LickPortBlockStart' 'task' 'beginning of a new block'

            'AutoWater'          'task' '1 if autowater trial - i.e. water was delivered at lickport entrance, 0 otherwise'
            'RewardDelivery'     'task' 'time when reward was delivered, if it was an autowater trial reward delivery would be at lickport entrance, otherwise at the beginning of answer period'
            'RewardSize'         'task' '1 large, 0 regular or omission'
            'RewardOmission'     'task' '0 no omission - i.e. regular or large reward, 1 omission'

            'Lick'               'lick' ''
            'LickTouch'          'lick' '' 
            'LickNoTouch'        'lick' ''
            'LickTouchReward'    'lick' ''
            'LickTouchNoReward'  'lick' ''
            'LickTouchNoRewardOmitted'  'lick' 'licks with touch on trials in which reward was omitted'

            'FirstLickTouch'     'task' ''
            'FirstLickReward'    'task' 'first lick with touch after reward was presented'

            'PawFrontLeft'       'move' 'Left Front Paw'
            'PawFrontRight'      'move' 'Right Front Paw'
            'Whiskers'           'move' 'Whiskers'
            'Nose'               'move' 'Nose'
            'Jaw'                'move' 'Jaw'
            };
    end
end

