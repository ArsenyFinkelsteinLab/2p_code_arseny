function [preferred_bin,idx_preferred_trials, idx_non_preferred_trials, preferred_radius ] ...
    = fn_compute_Lick2D_preferred_2d_tuning_radius ...
    (map_fr, mat_x, mat_z, num_trials, idx_xz, key, idx_response, idx_trial_condition)

    [~,preferred_bin]=nanmax(map_fr(:));
    preferred_radius = sqrt(mat_x(preferred_bin)^2 + mat_z(preferred_bin)^2) ;
    
    % preferred idx
    [~,I_max]=sort(map_fr(:));
    if key.number_of_bins>3
        idx_preferred_trials = ismember(1:1:num_trials,[idx_xz{I_max(end-1:end)}]) & idx_trial_condition; % we take 2 highest bin
    else
        idx_preferred_trials = ismember(1:1:num_trials,[idx_xz{I_max(end)}]) & idx_trial_condition; % we take 1 highest bin
    end
    % non preferred idx
    idx_non_preferred_trials = logical(1:1:num_trials);
    idx_non_preferred_trials (idx_preferred_trials | ~idx_response | ~idx_trial_condition)=0;