%{
# If this sessioon was recorded on  mesoscope
-> EXP2.SessionEpoch
-------------
flag_include             : boolean #
stimpower_percent        : float #
%}

classdef SessionEpochsIncluded < dj.Lookup
    properties
        contents = {
            447991 1 'spont_photo' 1  1  10   
            447991 1 'spont_photo' 2  1  15  
            
            447991 2 'spont_photo' 1  1  10  
            447991 2 'spont_photo' 2  1  15  
            
            447991 3 'spont_photo' 2  1  15  
            447991 3 'spont_photo' 4  1  15  
            
            447991 4 'spont_photo' 2  1  15  
            447991 4 'spont_photo' 5  1  15  
            
            447991 5 'spont_photo' 2  1  15  
            447991 5 'spont_photo' 5  1  15  
            
            447991 6 'spont_photo' 2  1  15  
            447991 6 'spont_photo' 5  1  15  
            
            447991 7 'spont_photo' 2  1  15  
            447991 7 'spont_photo' 5  1  15  
            
            447991 8 'spont_photo' 2  1  15  
            447991 8 'spont_photo' 5  1  15  
            
            447991 9 'spont_photo' 2  1  15  
            447991 9 'spont_photo' 5  1  15  
            
            447991 10 'spont_photo' 2  1  15  
            447991 10 'spont_photo' 5  1  15  
            
            447991 11 'spont_photo' 2  1  15  
            447991 11 'spont_photo' 5  1  15  
            
            
            %
            447990 1 'spont_photo' 2  1  5   
            447990 1 'spont_photo' 3  1  10  
            447990 1 'spont_photo' 4  1  15  
            
            447990 2 'spont_photo' 2  0  15  
            447990 2 'spont_photo' 5  1  15  
            
            447990 3 'spont_photo' 2  1  15  
            447990 3 'spont_photo' 5  1  15  
            
            447990 4 'spont_photo' 2  1  15  
            447990 4 'spont_photo' 5  1  15  
            
            447990 5 'spont_photo' 2  1  15  
            447990 5 'spont_photo' 5  1  15  
            
            447990 6 'spont_photo' 2  1  15  
            447990 6 'spont_photo' 5  1  15  
            
            447990 7 'spont_photo' 2  1  15  
            447990 7 'spont_photo' 5  1  15  
            
            447990 8 'spont_photo' 2  1  15  
            447990 8 'spont_photo' 5  1  15  
            
            
            %
            462458 1 'spont_photo' 1  1  5    % 4 per volume
            462458 1 'spont_photo' 2  1  10   % 4 per volume
            462458 1 'spont_photo' 3  1  15   % 4 per volume
            462458 1 'spont_photo' 4  0  15   % 4 per volume

            462458 2 'spont_photo' 1  1  10    % 4 per volume
            462458 2 'spont_photo' 2  1  15    % 4 per volume
            462458 2 'behav_photo' 3  1  10    % 4 per volume
            462458 2 'behav_photo' 4  1  15    % 4 per volume

            462458 3 'spont_photo' 1  1  10    % twice per volume
            462458 3 'spont_photo' 2  1  15    % twice per volume
            
            462458 4 'spont_photo' 1  1  15    % once per volume
            462458 4 'spont_photo' 2  1  15    % once per volume
            
            462458 5 'spont_photo' 2  1  15    % once per volume
            462458 5 'spont_photo' 5  1  15    % once per volume
            
            462458 6 'spont_photo' 1  1  15    % once per volume

            462458 7 'spont_photo' 2  1  15    % once per volume
            462458 7 'spont_photo' 5  1  15    % once per volume

            462458 8 'spont_photo' 1  1  15    % once per volume

            462458 9 'spont_photo' 2  1  15    % once per volume

           462458 10 'spont_photo' 2  1  15    % once per volume
           
           462458 11 'spont_photo' 2  1  15    % once per volume
           
           462458 12 'spont_photo' 2  1  15    % once per volume

           
           %
           462455 1 'spont_photo' 1  1  15    % once per volume

           462455 2 'spont_photo' 2  1  15    % once per volume
           462455 2 'spont_photo' 5  1  15    % once per volume

           462455 3 'spont_photo' 2  1  15    % once per volume

            
           
           %
            463195 1 'spont_photo' 1  1  5    % once per volume
            463195 1 'spont_photo' 2  1  15   % once per volume
            463195 1 'spont_photo' 3  1  15   % 2 per volume
            
           463195 2 'spont_photo' 2  1  15    % once per volume
           463195 2 'spont_photo' 4  1  15    % once per volume
           463195 2 'spont_photo' 6  1  15    % 2 per volume

           463195 3 'spont_photo' 2  1  15    % once per volume
           463195 3 'spont_photo' 5  1  15    % once per volume
           463195 3 'spont_photo' 6  0  15    % multiplexing
           
            463195 4 'spont_photo' 1  1  15   % once per volume
            463195 4 'spont_photo' 2  1  15   % once per volume
           
            
            %
            463192 1 'spont_photo' 2  1  15   % once per volume
            
            463192 2 'spont_photo' 2  1  15   % once per volume
                        
            463192 3 'spont_photo' 2  1  15   % once per volume

            
            %
%             445980
%             445873
            }
        
    end
end