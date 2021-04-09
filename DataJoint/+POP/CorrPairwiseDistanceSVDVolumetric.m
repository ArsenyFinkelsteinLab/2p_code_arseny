%{
# Pairwise correlation as a function of distance
-> EXP2.SessionEpoch
threshold_for_event             : double     # threshold in deltaf_overf
num_svd_components_removed      : int     # how many of the first svd components were removed
---
column_radius_vector                  :blob        # size of the columns
column_distance_corr_all                     :blob        # columns size X axial distance mat, average pairwise pearson coeff of cells within a column, binned according to axial distance between neurons
column_distance_corr_positive                :blob        # columns size X axial distance mat, average positive pairwise pearson coeff of cells within a column, binned according to axial distance between neurons
column_distance_corr_negative                :blob        # columns size X axial distance mat, average negative pairwise pearson coeff of cells within a column, binned according to axial distance between neurons
axial_distance_bins                   :blob        # axial bins
%}


classdef CorrPairwiseDistanceSVDVolumetric < dj.Computed
    properties
        keySource = ((EXP2.SessionEpoch  & IMG.ROI & IMG.ROIdeltaF & IMG.Mesoscope) - EXP2.SessionEpochSomatotopy)&IMG.Volumetric ;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            close all;
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            %             dir_save_fig = [dir_base  '\POP\corr_distance\'];
            
            
            time_bin=1.5; %s
            threshold_for_event_vector = [0, 0.25, 0.5];
            num_svd_components_removed_vector = [0, 1, 10, 100, 500];
            %              num_svd_components_removed_vector = [1000];
            
            column_radius_vector=[20:20:200];
            key.column_radius_vector = column_radius_vector;
            
            
            
            %             min_num_events = 20; %per hour
            imaging_frame_rate = fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            
            
            
            %% Loading Data
            
            roi_list=fetchn(IMG.ROIdeltaFNeuropilSubtr &key,'roi_number','ORDER BY roi_number');
            chunk_size=500;
            for i_chunk=1:chunk_size:numel(roi_list)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                if roi_interval(end)>numel(roi_list)
                    roi_interval(end) = numel(roi_list)+1;
                end
                temp_Fall=cell2mat(fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                temp_roi_num=fetchn(IMG.ROIdeltaF & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'roi_number','ORDER BY roi_number');
                Fall(temp_roi_num,:)=temp_Fall;
            end
            
            
            %% binning in time
            bin_size_in_frame=ceil(time_bin*imaging_frame_rate);
            
            bins_vector=1:bin_size_in_frame:size(Fall,2);
            bins_vector=bins_vector(2:1:end);
            for  i= 1:1:numel(bins_vector)
                ix1=(bins_vector(i)-bin_size_in_frame):1:(bins_vector(i)-1);
                F(:,i)=mean(Fall(:,ix1),2);
            end
            clear Fall temp_Fall
            
            
            %% Distance between all pairs
            
            x_all=fetchn(IMG.ROI &key,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(IMG.ROI &key,'roi_centroid_y','ORDER BY roi_number');
            z_all=fetchn(IMG.ROI*IMG.PlaneCoordinates & key,'z_pos_relative','ORDER BY roi_number');
            
            x_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(IMG.ROI*IMG.PlaneCoordinates &key,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative; x_all = x_all/0.75;
            y_all = y_all + y_pos_relative; y_all = y_all/0.5;
            
            
            
            dXY=zeros(numel(x_all),numel(x_all));
%             d3D=zeros(numel(x_all),numel(x_all));
            dZ=zeros(numel(z_all),numel(z_all));
            parfor iROI=1:1:numel(x_all)
                x=x_all(iROI);
                y=y_all(iROI);
                z=z_all(iROI);
                dXY(iROI,:)= sqrt((x_all-x).^2 + (y_all-y).^2); % in um
                dZ(iROI,:)= abs(z_all-z); % in um
%                 d3D(iROI,:) = sqrt((x_all-x).^2 + (y_all-y).^2 + (z_all-z).^2); % in um
            end
            
            axial_distance_bins = unique(dZ)';
            axial_distance_bins=[axial_distance_bins,inf];
            key.axial_distance_bins=axial_distance_bins;
            
            temp=logical(tril(dXY));
            idx_up_triangle=~temp;
            dZ = dZ(idx_up_triangle);
            dXY = dXY(idx_up_triangle);
            
            
            
            %% Thresholding activity and computing SVD and correlations
            
            for i_th = 1:1:numel(threshold_for_event_vector)
                threshold= threshold_for_event_vector(i_th);
                
                for i_c = 1:1:numel(num_svd_components_removed_vector)
                    
                    F_thresholded=F;
                    if threshold>0
                        F_thresholded(F<=threshold)=0;
                    end
                    %                     F_thresholded = F_thresholded(idx_enough_events,:);
                    rho=[];
                    F_thresholded = gpuArray((F_thresholded));
                    if num_svd_components_removed_vector(i_c)>0
                        num_comp = num_svd_components_removed_vector(i_c);
                        %                         F_thresholded = F_thresholded-mean(F_thresholded,2);
                        F_thresholded=zscore(F_thresholded,[],2);
                        
                        [U,S,V]=svd(F_thresholded); % S time X neurons; % U time X time;  V neurons x neurons
                        
                        singular_values =diag(S);
                        
                        variance_explained=singular_values.^2/sum(singular_values.^2); % a feature of SVD. proportion of variance explained by each component
                        %                         cumulative_variance_explained=cumsum(variance_explained);
                        
                        U=U(:,(1+num_comp):end);
                        %             S=S(1:num_comp,1:num_comp);
                        V=V(:,(1+num_comp):end);
                        S = S((1+num_comp):end, (1+num_comp):end);
                        
                        
                        F_reconstruct = U*S*V';
                        clear U S V F_thresholded
                        
                        try
                            rho=corrcoef(F_reconstruct');
                            rho=gather(rho);
                        catch
                            F_reconstruct=gather(F_reconstruct);
                            rho=corrcoef(F_reconstruct');
                        end
                    else
                        try
                            rho=corrcoef(F_thresholded');
                            rho=gather(rho);
                        catch
                            F_thresholded=gather(F_thresholded);
                            rho=corrcoef(F_thresholded');
                        end
                    end
                    
                    
                    rho = rho(idx_up_triangle);

                    %% Axial Distance dependence
                    for i_col=1:1:numel(column_radius_vector)
                        idx_within_column = dXY<=column_radius_vector(i_col);
                        
                        rho_column = rho(idx_within_column);
                        idx_positive = rho_column>0;
                        idx_negative = rho_column<=0;
                        
                        dZ_column = dZ(idx_within_column);
                        [~,~,bin] = histcounts(dZ_column,axial_distance_bins);
                        for i=1:1:numel(axial_distance_bins)-1
                            idx = (bin ==i);
                            column_distance_corr_all(i_col,i)=nanmean(rho_column(idx));
                            column_distance_corr_positive(i_col,i)=nanmean(rho_column(idx&idx_positive));
                            column_distance_corr_negative(i_col,i)=nanmean(rho_column(idx&idx_negative));
                        end
                        
                        key.column_distance_corr_all=column_distance_corr_all;
                        key.column_distance_corr_positive=column_distance_corr_positive;
                        key.column_distance_corr_negative=column_distance_corr_negative;
                        
                        %     %% 3D Distance dependence
                        %     % euclidean_distance_bins = lateral_distance_bins(2:end);
                        %     [N,~,bin] = histcounts(d3D(:),euclidean_distance_bins);
                        %     for i=1:1:numel(euclidean_distance_bins)-1
                        %         idx = (bin ==i);
                        %         dtheta_3Ddist_mean(i) = rad2deg(circ_mean(deg2rad(dtheta(idx))));
                        %         dtheta_3Ddist_var(i) = rad2deg(circ_var(deg2rad(dtheta(idx))))/sqrt(sum(idx));
                        %     end
                        %
                        %     %shuffled
                        %     idx_shuffled = randperm(numel(dtheta(:)));
                        %     for i=1:1:numel(euclidean_distance_bins)-1
                        %         idx = (bin ==i);
                        %         dtheta_shuffled = dtheta(idx_shuffled);
                        %         dtheta_3Ddist_shuffled(i) = rad2deg(circ_mean(deg2rad(dtheta_shuffled(idx))));
                        %     end
                        %
                        %     ax1=axes('position',[position_x2(5), position_y2(3), panel_width2, panel_height2]);
                        %     hold on;
                        %     plot(euclidean_distance_bins(1:1:end-1),dtheta_3Ddist_mean,'-r')
                        %     plot(euclidean_distance_bins(1:1:end-1),dtheta_3Ddist_shuffled,'-k')
                        %     ylim([0,110]);
                        %     xlabel('Euclidean (3D) distance (\mum)');
                        %     ylabel('\Delta\theta (\circ)');
                        %     title(sprintf('Preferred Direction \nEuclidean (3D)  distance'));
                        %     xlim([0,euclidean_distance_bins(end-1)]);
                        %     set(gca,'YTick',[0, 45, 90]);
                        
                        
                        
                        
                        % Bin correlation by distance
                        %                     kk=fn_POP_bin_pairwise_corr_by_distance(key, rho, dXY, threshold_for_event_vector, i_th,i_c, corr_histogram_bins, distance_bins, num_svd_components_removed_vector);
                        
                    end
                    key.threshold_for_event = threshold;
                    key.num_svd_components_removed = num_svd_components_removed_vector(i_c);
                    insert(self,key);
                    
                end
            end
            
            
            
            
            
        end
    end
end

