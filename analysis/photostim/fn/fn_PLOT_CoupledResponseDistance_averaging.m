function OUT=fn_PLOT_CoupledResponseDistance_averaging(D,distance_axial_bins, flag_response,  maxv, minv)
OUT=[];

distance_lateral_bins=D(1).distance_lateral_bins;
distance_lateral_bins_centers= distance_lateral_bins(1:end-1)+diff(distance_lateral_bins)/2;

% choosing sessions with the same number of axial bins
counter=0;
for j=1:1:numel(D)
    if~(numel(intersect(distance_axial_bins,D(j).distance_axial_bins'))==numel(distance_axial_bins))
        continue
    end
    counter=counter+1;
    idx_sessions(counter) = j;
end

% idx_sessions=1:1:numel(D);
if counter==0
    return
end
map=zeros(numel(distance_axial_bins), numel(distance_lateral_bins_centers),numel(idx_sessions))+NaN;
axial_marginal=zeros(numel(idx_sessions),numel(distance_axial_bins))+NaN;
axial_marginal_in_column=zeros(numel(idx_sessions),numel(distance_axial_bins))+NaN;
axial_marginal_out_column=zeros(numel(idx_sessions),numel(distance_axial_bins))+NaN;


num_pairs=0;
for j=1:1:numel(idx_sessions)
    ii= idx_sessions(j);
    num_pairs=num_pairs+D(j).num_pairs;
    switch flag_response
        case 0 %all
            current_map = D(ii).response_2d;
            current_lateral = D(ii).response_lateral;
            current_axial = D(ii).response_axial';
            current_axial_in_column = D(ii).response_axial_in_column';
            current_axial_out_column = D(ii).response_axial_out_column';
        case 1 %excitation
            current_map = D(ii).response_2d_excitation;
            current_lateral = D(ii).response_lateral_excitation;
            current_axial = D(ii).response_axial_excitation';
            current_axial_in_column = D(ii).response_axial_in_column_excitation';
            current_axial_out_column = D(ii).response_axial_out_column_excitation';
        case 2 %inhibition
            current_map = D(ii).response_2d_inhibition;
            current_lateral = D(ii).response_lateral_inhibition;
            current_axial = D(ii).response_axial_inhibition';
            current_axial_in_column = D(ii).response_axial_in_column_inhibition';
            current_axial_out_column = D(ii).response_axial_out_column_inhibition';
        case 3 %absolute
            current_map = D(ii).response_2d_absolute;
            current_lateral = D(ii).response_lateral_absolute;
            current_axial = D(ii).response_axial_absolute';
            current_axial_in_column = D(ii).response_axial_in_column_absolute';
            current_axial_out_column = D(ii).response_axial_out_column_absolute';
    end
    
    %     current_map_without_NaN = current_map;  current_map_without_NaN(isnan(current_map))=0;
    %     current_axial_without_NaN = current_axial;  current_axial_without_NaN(isnan(current_axial))=0;
    
    lateral_marginal(j,:) = current_lateral;
    
    
    current_axial_bins = D(j).distance_axial_bins;
    for i_d=1:1:numel(current_axial_bins)
        idx_d=find(current_axial_bins(i_d)==distance_axial_bins);
        %         temp=~isnan(current_map(i_d,:));
        %         session_counts(distance_axial_bins==current_axial_bins(i_d),:)= session_counts(distance_axial_bins==current_axial_bins(i_d),:)+temp;
        if ~isempty(idx_d)
            map(idx_d,:,j) = current_map(i_d,:);
            axial_marginal(j,idx_d) = current_axial(i_d,:);
            axial_marginal_in_column(j,idx_d) = current_axial_in_column(i_d,:);
            axial_marginal_out_column(j,idx_d) = current_axial_out_column(i_d,:);

        end
    end
end

map=squeeze(nanmean(map,3));

if nargin<4 % if the scaling values were not provided as inputs
    maxv=prctile(map(:),99);
    minv=min([prctile(map(:),1),0]);
end

%rescaling
map(map>=maxv)=maxv;
map(map<=minv)=minv;

OUT.distance_lateral_bins_centers=distance_lateral_bins_centers;
OUT.maxv=maxv;
OUT.minv=minv;
OUT.num_pairs=num_pairs;

OUT.map=map; %map averaged across sessions
OUT.map(2:5,:)=OUT.map;
OUT.marginal_lateral_mean=nanmean(lateral_marginal,1);
OUT.marginal_lateral_stem=nanstd(lateral_marginal,1)./sqrt(sum(~isnan(lateral_marginal)));

OUT.marginal_axial_mean=nanmean(axial_marginal,1);
OUT.marginal_axial_stem=nanstd(axial_marginal,1)./sqrt(sum(~isnan(axial_marginal)));

OUT.marginal_axial_in_column_mean=nanmean(axial_marginal_in_column,1);
OUT.marginal_axial_in_column_stem=nanstd(axial_marginal_in_column,1)./sqrt(sum(~isnan(axial_marginal_in_column)));

OUT.marginal_axial_out_column_mean=nanmean(axial_marginal_out_column,1);
OUT.marginal_axial_out_column_stem=nanstd(axial_marginal_out_column,1)./sqrt(sum(~isnan(axial_marginal_out_column)));




