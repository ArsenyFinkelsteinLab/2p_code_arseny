%{
#
-> TRACKING.TrackingDevice
video_fiducial_name         : varchar(200)                  #
---
video_fiducial_description  : varchar(1000)                 #
%}


classdef VideoFiducialsType < dj.Lookup
    properties
        contents = {
            'imaging1'    'Camera'                3    'jaw'               'bottom edge of the jaw/mouth'
            'imaging1'    'Camera'                3    'nosetip'           'anterior edge of the nose'
            'imaging1'    'Camera'                3    'lickport'          'tip of the port'
            'imaging1'    'Camera'                3    'tonguemiddle'      'middle of the tongue'
            'imaging1'    'Camera'                3    'TongueTip'         'tip of the tongue, the most bottom part'
            'imaging1'    'Camera'                3    'PawL'              'left paw'
            'imaging1'    'Camera'                3    'PawR'              'right paw'
            
            'imaging1'    'Camera'                3    'W1'                 'whisker, one of the frontal whiskers'
            'imaging1'    'Camera'                3    'W2'                 'whisker, one of the middle whiskers'
            'imaging1'    'Camera'                3    'W3'                 'whisker, one of the backward whiskers'
            
            
            'imaging1'    'Camera'                4    'jaw'               'bottom edge of the jaw/mouth'
            'imaging1'    'Camera'                4    'nosetip'           'center of the nose'
            'imaging1'    'Camera'                4    'lickport'          'tip of the port'
            
            'imaging1'    'Camera'                4    'LBtongue'          'left backward edge of the tongue'
            'imaging1'    'Camera'                4    'LFtongue'          'left frontal edge  of the tongue'
            'imaging1'    'Camera'                4    'RBtongue'          'right backward edge of the tongue'
            'imaging1'    'Camera'                4    'RFtongue'          'right frontal edge  of the tongue'
            'imaging1'    'Camera'                4    'TongueTip'         'tip of the tongue, the most front part'
            
            'imaging1'    'Camera'                4    'PawL'              'left paw'
            'imaging1'    'Camera'                4    'PawR'              'right paw'
            };
        
        
        %             insert(self,video_fiducial_name);
        
        
    end
end

