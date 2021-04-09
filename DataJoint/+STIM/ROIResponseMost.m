%{ 
# Taking most responsive neurons 
-> IMG.PhotostimGroup
-> IMG.ROI
---
most_response_mean          : double                # (pixels)
most_response_min          : double                # (pixels)
most_response_max         : double                # (pixels)
most_response_p_value          : double                # (pixels)
most_response_distance_pixels          : double                # (pixels)
%}


classdef ROIResponseMost < dj.Imported
    properties
        %         keySource = IMG.PhotostimGroup;
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.FOV;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            distance_to_closest_neuron=30; % in microns

            group_num=  fetchn(IMG.PhotostimGroup & key,'photostim_group_num','ORDER BY photostim_group_num');
                
            temp = fetch(IMG.Plane & key);
            key.fov_num =  temp.fov_num;
            key.plane_num =  1;
            key.channel_num =  temp.channel_num;
            
            
               zoom =fetch1(IMG.FOVEpoch & key,'zoom');
            kkk.scanimage_zoom = zoom;
            pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
            distance_to_closest_neuron_pixels = distance_to_closest_neuron/pix2dist; % in pixels

            
            k1=key;
            for i_g = 1:1:numel(group_num)
                k1.photostim_group_num = group_num(i_g);
%                 C=fetch(STIM.ROIResponse50 & IMG.ROIGood & k1 & 'response_p_value<=0.01'  & sprintf('response_distance_pixels <%.2f', distance_to_closest_neuron_pixels),'*', 'ORDER BY response_mean');
                C=fetch(STIM.ROIResponse & IMG.ROIGood & k1 & 'response_p_value<=0.05'  & sprintf('response_distance_pixels <%.2f', distance_to_closest_neuron_pixels),'*', 'ORDER BY response_mean');

                k2=k1;
                if ~isempty(C)
                    k2.roi_number=C(end).roi_number;
                    k2.most_response_mean=C(end).response_mean;
                    k2.most_response_max=C(end).response_max;
                    k2.most_response_min=C(end).response_min;
                    k2.most_response_p_value=C(end).response_p_value;
                    k2.most_response_distance_pixels=C(end).response_distance_pixels;
                    insert(self, k2);
                end
            end
        end
    end
end