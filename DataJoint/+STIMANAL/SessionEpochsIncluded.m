%{
# If this sessioon was recorded on  mesoscope
-> EXP2.SessionEpoch
-------------
flag_include                    : boolean          #
stimpower                       : float            # in mW
targets_per_volume = null         : int            # if volumetric imaging -- how many different targets are photostimulated per volume scan. NaN if not volumetric NaN
session_comment                 : varchar(4000)    # 
%}

classdef SessionEpochsIncluded < dj.Lookup
    properties
        contents = {
            
            % To be filled in:
            %             445980 (st 66)
            %             445873 (st 68)
            
            447991 1 'spont_photo' 1  1  100 NaN 'not volumetric'
            447991 1 'spont_photo' 2  1  150 NaN 'not volumetric'
            
            447991 2 'spont_photo' 1  1  100 NaN 'not volumetric'
            447991 2 'spont_photo' 2  1  150 NaN 'not volumetric'
            
            447991 3 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 3 'spont_photo' 4  1  150 NaN 'not volumetric'
            
            447991 4 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 4 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447991 5 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 5 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447991 6 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 6 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447991 7 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 7 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447991 8 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 8 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447991 9 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 9 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447991 10 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 10 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447991 11 'spont_photo' 2  1  150 NaN 'not volumetric'
            447991 11 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            
            %
            447990 1 'spont_photo' 2  1  50  NaN 'not volumetric'
            447990 1 'spont_photo' 3  1  100 NaN 'not volumetric'
            447990 1 'spont_photo' 4  1  150 NaN 'not volumetric'
            
            447990 2 'spont_photo' 2  1  150 NaN 'not volumetric'
            447990 2 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447990 3 'spont_photo' 2  1  150 NaN 'not volumetric'
            447990 3 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447990 4 'spont_photo' 2  1  150 NaN 'not volumetric'
            447990 4 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447990 5 'spont_photo' 2  1  150 NaN 'not volumetric'
            447990 5 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447990 6 'spont_photo' 2  1  150 NaN 'not volumetric'
            447990 6 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447990 7 'spont_photo' 2  1  150 NaN 'not volumetric'
            447990 7 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            447990 8 'spont_photo' 2  1  150 NaN 'not volumetric'
            447990 8 'spont_photo' 5  1  150 NaN 'not volumetric'
            
            
            %
            462458 1 'spont_photo' 1  1  50    4 'target switches every frame -- 4 times per volume'
            462458 1 'spont_photo' 2  1  100   4 'target switches every frame -- 4 times per volume'
            462458 1 'spont_photo' 3  1  150   4 'target switches every frame -- 4 times per volume'
            462458 1 'spont_photo' 4  0  150   4 'target switches every frame -- 4 times per volume cross shape'
            
            462458 2 'spont_photo' 1  1  100    4 'target switches every frame -- 4 times per volume'
            462458 2 'spont_photo' 2  1  150    4 'target switches every frame -- 4 times per volume'
            462458 2 'behav_photo' 3  1  100    4 'target switches every frame -- 4 times per volume'
            462458 2 'behav_photo' 4  1  150    4 'target switches every frame -- 4 times per volume'
            
            462458 3 'spont_photo' 1  1  100    2 'target switches every 2 frames -- 2 times per volume'
            462458 3 'spont_photo' 2  1  150    2 'target switches every 2 frames -- 2 times per volume'
            
            462458 4 'spont_photo' 1  1  150    1 'target switches every 4 frames -- 1 time per volume'
            462458 4 'spont_photo' 2  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            462458 5 'spont_photo' 2  1  150    1 'target switches every 4 frames -- 1 time per volume'
            462458 5 'spont_photo' 5  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            462458 6 'spont_photo' 1  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            462458 7 'spont_photo' 2  1  150    1 'target switches every 4 frames -- 1 time per volume'
            462458 7 'spont_photo' 5  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            462458 8 'spont_photo' 1  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            462458 9 'spont_photo' 2  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            462458 10 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            
            462458 11 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            
            462458 12 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            
            
            %
            462455 1 'spont_photo' 1  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            462455 2 'spont_photo' 2  1  150    1 'target switches every 4 frames -- 1 time per volume'
            462455 2 'spont_photo' 5  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            462455 3 'spont_photo' 2  1  150    1 'target switches every 4 frames -- 1 time per volume'
            
            
            
            %
            463195 1 'spont_photo' 1  1  50    1 'target switches every 4 frames -- 1 time per volume'
            463195 1 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            463195 1 'spont_photo' 3  1  150   2 'target switches every 2 frames -- 2 times per volume'
            
            463195 2 'spont_photo' 2  1  150    1 'target switches every 4 frames -- 1 time per volume'
            463195 2 'spont_photo' 4  1  150    1 'target switches every 4 frames -- 1 time per volume'
            463195 2 'spont_photo' 6  1  150    2 'target switches every 2 frames -- 2 times per volume'
            
            463195 3 'spont_photo' 2  1  150    1 'target switches every 4 frames -- 1 time per volume'
            463195 3 'spont_photo' 5  1  150    1 'target switches every 4 frames -- 1 time per volume'
            463195 3 'spont_photo' 6  0  150    NaN 'multiplexing'
            
            463195 4 'spont_photo' 1  1  150   1 'target switches every 4 frames -- 1 time per volume'
            463195 4 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            
            
            %
            463192 1 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            
            463192 2 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            
            463192 3 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            
            
            % weak photostimulation
            462451 1 'spont_photo' 1  1  150   1 'target switches every 4 frames -- 1 time per volume'

            % weak photostimulation
            464728 1 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            464728 2 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'

            
            
            %
            486673 1 'spont_photo' 2  1  50    1 'target switches every 4 frames -- 1 time per volume'
            486673 1 'spont_photo' 3  1  100    1 'target switches every 4 frames -- 1 time per volume'
            486673 1 'spont_photo' 4  1  150   1 'target switches every 4 frames -- 1 time per volume'
            
            486673 3 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'

            486673 4 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            
            486673 5 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'

            
            %
            486668 2 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            
            486668 3 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            
            486668 4 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            
            486668 5 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'

            486668 6 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            
            %
            490663 1 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            490663 2 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            490663 3 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            490663 4 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume. Mouse rotated 45 deg in azimuth rightwards from the mouse perspective to control for PSF'

            
               %
            492791 1 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            492791 2 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            492791 3 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            492791 4 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume. Mouse rotated 45 deg in azimuth rightwards from the mouse perspective to control for PSF'

            
            480483 1 'spont_photo' 2  1  170   1 'target switches every 4 frames -- 1 time per volume'
            480483 2 'spont_photo' 2  1  170   1 'target switches every 4 frames -- 1 time per volume'
            480483 3 'spont_photo' 2  1  170   1 'target switches every 4 frames -- 1 time per volume'
            480483 4 'spont_photo' 2  1  170   1 'target switches every 4 frames -- 1 time per volume'
            480483 5 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            480483 6 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            480483 7 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume. Mouse rotated 80 deg in azimuth rightwards from the mouse perspective to control for PSF'

            496552 1 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            496552 2 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            496552 3 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'

            496912 1 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            496912 2 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            496912 3 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            496912 4 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'

            491362 1 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            491362 2 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            491362 2 'spont_photo' 3  1  200   1 'target switches every 4 frames -- 1 time per volume'

            
            496916 1 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            496916 2 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'
            496916 3 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            496916 5 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
            496916 6 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'

            494561 1 'spont_photo' 2  1  100   1 'target switches every 4 frames -- 1 time per volume'

            495875 1 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'
                  
            495876 1 'spont_photo' 2  1  150   1 'target switches every 4 frames -- 1 time per volume'

            
            }
        
    end
end