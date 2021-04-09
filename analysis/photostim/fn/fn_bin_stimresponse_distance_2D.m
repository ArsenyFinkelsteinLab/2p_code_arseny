function OUTPUT =fn_bin_stimresponse_distance_2D(rel, k1, neurons_or_control_flag, pix2dist, distance_lateral_bins)

if neurons_or_control_flag == 0
%     rel_group_targets=rel & (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & (STIM.ROIResponseDirect &'response_p_value<0.01'))& k1);
    rel_group_targets =  rel & (IMG.PhotostimGroup & (STIM.ROIResponseDirect & k1 & 'response_p_value<=0.01')) & k1;

    elseif neurons_or_control_flag == 1
    rel_group_targets =  rel & (IMG.PhotostimGroup & (STIM.ROIResponseDirect & k1 & 'response_p_value>0.1')) & k1;
end

    %     rel_group_neurons=rel & (IMG.PhotostimGroup & (IMG.PhotostimGroupROI & STIM.ROIResponseDirect & 'flag_neuron_or_control=0' & 'distance_to_closest_neuron>10')& k1);
    DATA=fetch(rel_group_targets,'*');
    F_mean=[DATA.response_mean]';
    distance_lateral=[DATA.response_distance_pixels]';
   distance_lateral=pix2dist*distance_lateral;
   distance_axial=[DATA.response_distance_axial_um]';
    
   distance_axial_bins = unique(distance_axial);
    
    
    ix_excit= F_mean>0;
    ix_inhbit= F_mean<0;
    num_roi_bin_all =[];
    num_roi_bin_excit =[];
    num_roi_bin_inhibit =[];
    
    for i_l=1:1:numel(distance_lateral_bins)-1
        ix_l = distance_lateral>=distance_lateral_bins(i_l) & distance_lateral<distance_lateral_bins(i_l+1);
        for i_a = 1:1:numel(distance_axial_bins)
        ix_a = distance_axial==distance_axial_bins(i_a);
        num_roi_bin_all(i_l,i_a)=sum(ix_l & ix_a);
        num_roi_bin_excit(i_l,i_a) =sum(ix_l & ix_a & ix_excit);
        num_roi_bin_inhibit(i_l,i_a) =sum(ix_l & ix_a & ix_inhbit);
        mean_by_distance(i_l,i_a) =mean(F_mean(ix_l & ix_a));
        end
    end
    
    OUTPUT.distance_lateral=distance_lateral;
    OUTPUT.distance_axial_bins=distance_axial_bins;
    OUTPUT.distance_axial=distance_axial;
    OUTPUT.F_mean=F_mean;
    OUTPUT.mean_by_distance = mean_by_distance;
    OUTPUT.num_roi_bin_all = num_roi_bin_all;
    OUTPUT.num_roi_bin_excit = num_roi_bin_excit;
    OUTPUT.num_roi_bin_inhibit = num_roi_bin_inhibit;
