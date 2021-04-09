function  [similarity_local,similarity_local_shuffled] = fn_local_similarity_space(ROI_WEIGHTS,x_all, y_all, radius_size, min_lateral_distance )

similarity_local  = cell(size(ROI_WEIGHTS,1),1);
similarity_local_shuffled = cell(size(ROI_WEIGHTS,1),1);
parfor iROI=1:1:size(ROI_WEIGHTS,1)
    
    x=x_all(iROI);
    y=y_all(iROI);
    %     z=z_all(ii);
    %     dZ(ii,:)= abs(z_all - z); % in um
    %     d3D(ii,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
    
    dXY= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
    idx_within_outer_radius = find(dXY<=radius_size);
    current_dXY = dXY(idx_within_outer_radius);
    idx_within_inner_radius = find(current_dXY<min_lateral_distance);
    idx_within_outer_radius(idx_within_inner_radius)=[];
    
    
    CI=[];
    CI_shuffled=[];
    for i_c = 1:1:min(size(ROI_WEIGHTS,2),1000)
        i_c;
        W = ROI_WEIGHTS(:,i_c);
        
        w_seed = W(iROI);
        
        w_neighbors = W(idx_within_outer_radius);
        CI(i_c) = mean(abs((w_seed - w_neighbors))./(abs(w_seed) + abs(w_neighbors)));
        
        %shuffled
        idx_shuffled = randperm(size(W,1),numel(idx_within_outer_radius));
        w_neighbors = W(idx_shuffled);
        CI_shuffled(i_c) = mean(abs((w_seed - w_neighbors))./(abs(w_seed) + abs(w_neighbors)));
    end
    similarity_local{iROI} = CI;
    similarity_local_shuffled {iROI} =CI_shuffled;
    
end
