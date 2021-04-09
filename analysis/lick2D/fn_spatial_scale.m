function  [distance_tau, rd_distance_components] = fn_spatial_scale(ROI_WEIGHTS,DISTANCE_IDX,idx_up_triangle, distance_bins_centers, num_components)

distance_tau = zeros(num_components,1);
rd_distance_components=zeros(num_components,size(DISTANCE_IDX,2));

parfor i_c = 1:1:num_components
    
    W = ROI_WEIGHTS(:,i_c);

    Wdiff_mat= abs((W - W'))./max(abs(W),abs(W)');
    Wdiff_mat = Wdiff_mat(idx_up_triangle);
    
    %shuffled
    W_shuffled = W(randperm(size(W,1)));
    Wdiff_mat_shuffled= abs((W_shuffled - W_shuffled'))./max(abs(W_shuffled),abs(W_shuffled)');
    Wdiff_mat_shuffled = Wdiff_mat_shuffled(idx_up_triangle);

    RD_shuffled = nanmean(Wdiff_mat_shuffled);
    RD_distance=zeros(1,size(DISTANCE_IDX,2));
    for i_d = 1:1:size(DISTANCE_IDX,2)
        RD_distance(i_d)  = RD_shuffled - nanmean(Wdiff_mat(DISTANCE_IDX{i_d})); %relative difference
    end

    %  plot(distance_bins_centers, RD_distance_components)
    idx_distance =  find(RD_distance<=0,1,'first');

    rd_distance_components(i_c,:) = RD_distance;
    
    if ~isempty(idx_distance)
        distance_tau(i_c) = distance_bins_centers(idx_distance);
    else
        distance_tau(i_c) = distance_bins_centers(end-1);
    end
    
    
end

%

