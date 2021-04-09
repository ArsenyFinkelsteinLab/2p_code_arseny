function fn_insert_map_activity (M_avg,  smoothing_2D_size, baselineF_2D, key, self)

%% f
key.fov_map_activity_f = mean(M_avg,3);

key.fov_map_activity_f = mean(M_avg,3);

%% df/f
M_avg_temp = M_avg;
M_avg_temp=rescale(M_avg_temp);
for i_fr=1:1:size(M_avg,3)
    f=M_avg_temp(:,:,i_fr);
    M_avg_temp(:,:,i_fr) = (f-baselineF_2D)./baselineF_2D; %pixel by pixel bf/f
end

M_avg_temp = smooth3(M_avg_temp,'gaussian',smoothing_3D_size); %3D smoothing in x-y-z

key.fov_map_activity_dff = mean(M_avg_temp,3);

insert(self,key);