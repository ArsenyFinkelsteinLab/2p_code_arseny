%{
#
parameter_name                     :  varchar(200)
---
parameter_value  = null            : blob
parameter_description= null        :  varchar(4000)
%}

classdef Parameters < dj.Lookup
     properties
        contents = { 
            'dir_raw_data_scan_image' 'F:\Arseny\2p\data\'  ''
            'fov_size_microns_z1.1' 891.4  'field of view size in microns for zoom x1.1'
            'fov_size_microns_z1.3' 738.2  'field of view size in microns for zoom x1.3'
            'dir_root_save' 'F:\Arseny\2p\Results\'  ''
            'dir_video_processed' 'G:\Arseny\2p\video_processed\'  ''
            }
    end
end


