function [map_f_smoothed, map_dff_smoothed] = fn_compute_map_dff2 (map,  smoothing_3D_size, baselineF_2D, z_score_threshold, blank_idx)



%% df/f
% map_f_smoothed  =zeros(size(map));
% map_dff_smoothed =zeros(size(map));
map_dff =zeros(size(map));
map_f =zeros(size(map));

for i_fr=1:1:size(map,3)
    f=map(:,:,i_fr);
    deltaf=f-baselineF_2D;
    deltaf(blank_idx)=0;
%     z=zscore(deltaf(:));
%     idx_remove=abs(z)<z_score_threshold;
    dff=(deltaf)./baselineF_2D;
%     dff(idx_remove)=0; % remove small values (noise)
    
%     idx_outliers = abs(zscore(dff(:)))>10;
%     dff(idx_outliers)=0; % remove any remaining outliers due to division by small numbers
    
    %       map_f_smoothed(:,:,i_fr) = smooth2a(f, smoothing_2D_size, smoothing_2D_size); %
    %     map_dff_smoothed(:,:,i_fr) =  smooth2a(dff, smoothing_2D_size, smoothing_2D_size); %pixel by pixel df/f
    map_dff(:,:,i_fr)=dff;
    %     map_f_smoothed(:,:,i_fr) = smooth2a(f, smoothing_2D_size, smoothing_2D_size); %
    %     map_dff_smoothed(:,:,i_fr) =  smooth2a(dff, smoothing_2D_size, smoothing_2D_size); %pixel by pixel df/f
    f(blank_idx)=0;
    map_f(:,:,i_fr)=f;
    
end
% smoothing_3D_size=5;
map_dff_smoothed = smooth3(map_dff,'gaussian',smoothing_3D_size); %3D smoothing in x-y-z
map_f_smoothed = smooth3(map_f,'gaussian',smoothing_3D_size); %3D smoothing in x-y-z

