function OUTPUT =fn_bin_stimresponse_distance(rel, k1, neurons_or_control_flag,flag_distance_flag, pix2dist, distance_bins_microns)

if neurons_or_control_flag == 1
%     rel_group_targets=rel & (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & (STIM.ROIResponseDirect &'response_p_value<0.01'))& k1);
    rel_group_targets =  rel & (IMG.PhotostimGroup & (STIM.ROIResponseDirect & k1 & 'response_p_value<=0.01')) & k1;

    elseif neurons_or_control_flag == 0
    rel_group_targets =  rel & (IMG.PhotostimGroup & (STIM.ROIResponseDirect & k1 & 'response_p_value>0.1')) & k1;
end

    %     rel_group_neurons=rel & (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & STIM.ROIResponseDirect & 'flag_neuron_or_control=0' & 'distance_to_closest_neuron>10')& k1);
    DATA=fetch(rel_group_targets,'*');
    F_mean=[DATA.response_mean]';
    if flag_distance_flag==0 % lateral distance
        distance=[DATA.response_distance_pixels]';
        distance=pix2dist*distance;
    elseif flag_distance_flag==1 % axial distance
        distance=[DATA.response_distance_axial_um]';
    elseif flag_distance_flag==2 % 3D distance
        distance=[DATA.response_distance_3d_um]';
    end
    
    ix_excit= F_mean>0;
    ix_inhbit= F_mean<0;
    num_roi_bin_all =[];
    num_roi_bin_excit =[];
    num_roi_bin_inhibit =[];
    
    for i_d=1:1:numel(distance_bins_microns)-1
        ix_d = distance>=distance_bins_microns(i_d) & distance<distance_bins_microns(i_d+1);
        num_roi_bin_all(i_d)=sum(ix_d);
        num_roi_bin_excit(i_d) =sum(ix_d & ix_excit);
        num_roi_bin_inhibit(i_d) =sum(ix_d & ix_inhbit);
        mean_by_distance(i_d) =mean(F_mean(ix_d));
    end
    
    OUTPUT.distance=distance;
    OUTPUT.F_mean=F_mean;
    OUTPUT.mean_by_distance = mean_by_distance;
    OUTPUT.num_roi_bin_all = num_roi_bin_all;
    OUTPUT.num_roi_bin_excit = num_roi_bin_excit;
    OUTPUT.num_roi_bin_inhibit = num_roi_bin_inhibit;
