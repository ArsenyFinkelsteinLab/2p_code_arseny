function fn_local_correlations_space(key, key_ROI,F,x_all, y_all, radius_size,self, min_lateral_distance )

parfor iROI=1:1:size(F,1)
    
    x=x_all(iROI);
    y=y_all(iROI);
    %     z=z_all(ii);
    %     dZ(ii,:)= abs(z_all - z); % in um
    %     d3D(ii,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
    
    dXY= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
    idx_within_radius = find(dXY<=radius_size);
    
    current_dXY = dXY(idx_within_radius);
    idx_within_inner_ring = find(current_dXY<min_lateral_distance);
    
    if  numel(idx_within_radius)>1 % in case there are any cells in the neighborhood
        idx_current_cell =find(idx_within_radius==iROI);
        %         [rho,pval]=corr(Fall(idx_to_use,:)');
        [rho]=corrcoef(F(idx_within_radius,:)');
        
        idx_other_cells = true(size(idx_within_radius));
        idx_other_cells(idx_current_cell)=0;
        
        idx_other_cells_without_inner_ring  =idx_other_cells;
        idx_other_cells_without_inner_ring (idx_within_inner_ring)=0;
        
        corr_local = mean(rho(idx_current_cell,idx_other_cells));
        key_ROI(iROI).corr_local = corr_local;
        
        % if there are cells in the vinicity, even after removing the inner ring
        if sum(idx_other_cells_without_inner_ring)>0
            key_ROI(iROI).corr_local_without_inner_ring = mean(rho(idx_current_cell,idx_other_cells_without_inner_ring));
        else
            key_ROI(iROI).corr_local_without_inner_ring =NaN;
        end
        key_ROI(iROI).num_neurons_in_radius = numel(idx_within_radius);
        key_ROI(iROI).num_neurons_in_radius_without_inner_ring = numel(idx_other_cells_without_inner_ring);
        
        
        
    else % if there are no cells in the vicinity
        key_ROI(iROI).corr_local =NaN;
        key_ROI(iROI).corr_local_without_inner_ring =NaN;
        key_ROI(iROI).num_neurons_in_radius =0;
        key_ROI(iROI).num_neurons_in_radius_without_inner_ring = 0;
        
    end
    
    key_ROI(iROI).session_epoch_type = key.session_epoch_type;
    key_ROI(iROI).session_epoch_number = key.session_epoch_number;
    key_ROI(iROI).radius_size = radius_size;
    key_ROI(iROI).num_svd_components_removed=key.num_svd_components_removed;
    
end

insert(self,key_ROI);