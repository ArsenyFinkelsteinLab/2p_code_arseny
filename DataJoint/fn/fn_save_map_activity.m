function fn_save_map_activity (M_avg, baselineF_2D, key, self)

%% f
key.fov_map_activity_f = mean(M_avg,3);

%% df/f
key.fov_map_activity_dff = mean(M_avg,3) - baselineF_2D;

insert(self,key);