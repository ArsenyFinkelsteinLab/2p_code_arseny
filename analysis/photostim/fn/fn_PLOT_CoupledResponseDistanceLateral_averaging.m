function OUT=fn_PLOT_CoupledResponseDistanceLateral_averaging(D, flag_response)
OUT=[];

distance_lateral_bins=D(1).distance_lateral_bins;
distance_lateral_bins_centers= distance_lateral_bins(1:end-1)+diff(distance_lateral_bins)/2;


num_pairs=0;
for ii=1:1:numel(D)
    num_pairs=num_pairs+D(ii).num_pairs;
    switch flag_response
        case 0 %all
            current_lateral = D(ii).response_lateral;
                 case 1 %excitation
            current_lateral = D(ii).response_lateral_excitation;
                case 2 %inhibition
            current_lateral = D(ii).response_lateral_inhibition;
                 case 3 %absolute
            current_lateral = D(ii).response_lateral_absolute;
               end
    
    
    lateral_marginal(ii,:) = current_lateral;
    
end

OUT.distance_lateral_bins_centers=distance_lateral_bins_centers;
OUT.num_pairs=num_pairs;

OUT.marginal_lateral_mean=nanmean(lateral_marginal,1);
OUT.marginal_lateral_stem=nanstd(lateral_marginal,1)./sqrt(sum(~isnan(lateral_marginal)));


