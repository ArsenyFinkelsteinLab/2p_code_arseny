%{
# Pairwise correlation as a function of distance, binned in 2D lateral X axial distance
-> EXP2.SessionEpoch
threshold_for_event             : double  # threshold in deltaf_overf
num_svd_components_removed      : int     # how many of the first svd components were removed
---
distance_corr_all                     :blob      # mat of average pairwise pearson coeff of cells, binned according lateral X axial distance
distance_corr_positive                :blob      # mat of positive average pairwise pearson coeff of cells, binned according lateral X axial distance
distance_corr_negative                :blob      # mat of negative pairwise pearson coeff of cells, binned according lateral X axial distance
axial_distance_bins                   :blob      # axial bins
lateral_distance_bins                 :blob      # axial bins
%}


classdef CorrPairwiseDistanceSVDVoxels < dj.Computed
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
            threshold_for_event_vector = [0, 0.25];
            num_svd_components_removed_vector = [0, 1, 10, 100, 500];
            %              num_svd_components_removed_vector = [1000];
            
            lateral_distance_bins=[0:10:190,200:20:1000];
            key.lateral_distance_bins = lateral_distance_bins;
            
            
            
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
            
            axial_distance_bins =unique((z_all))';
            key.axial_distance_bins=axial_distance_bins;
            
            
            temp=logical(tril(dXY));
            idx_up_triangle=~temp;
            dXY = dXY(idx_up_triangle);
            dZ = dZ(idx_up_triangle);
            
            idx_local=dXY>5 & dXY<=max(lateral_distance_bins);
            dXY=dXY(idx_local);
            dZ=dZ(idx_local);
            
            
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
                    
%                     diag_mat=diag(ones(1,numel(roi_list)));
%                     idx_diag=diag_mat(:)==1;
%                     rho(idx_diag)=NaN;
                    rho = rho(idx_up_triangle);
                    rho=rho(idx_local); %also gets rid of diagonal elements
                    
                    
                    %% 2D binning according to lateral and axial distnace
                    distance_corr_all=zeros(numel(lateral_distance_bins)-1,numel(axial_distance_bins));
                    distance_corr_positive=zeros(numel(lateral_distance_bins)-1,numel(axial_distance_bins));
                    distance_corr_negative=zeros(numel(lateral_distance_bins)-1,numel(axial_distance_bins));
                    for i_l=1:1:numel(lateral_distance_bins)-1
                        idx_lateral = dXY>lateral_distance_bins(i_l) & dXY<=lateral_distance_bins(i_l+1);
%                         dXY_temp=dXY(idx_lateral);
                        dz_temp=dZ(idx_lateral);
                        rho_temp=rho(idx_lateral);
                        parfor i_a=1:1:numel(axial_distance_bins)
                            idx_axial =  dz_temp==axial_distance_bins(i_a);
%                             if i_a==2
%                                 idx_axial = idx_axial& dXY_temp>5; % pairs of neurons in the adjacent plane to the seed neuron (top plane in our case) within 5um distance form the seed neuron are removed to avoid contribution from auto-focus floursence
%                             end
                            rho_bin = rho_temp(idx_axial);
                            idx_positive = rho_bin>0;
                            idx_negative = rho_bin<0;
                            
                            distance_corr_all(i_l,i_a)=nanmean(rho_bin);
                            distance_corr_positive(i_l,i_a)=nanmean(rho_bin(idx_positive));
                            distance_corr_negative(i_l,i_a)=nanmean(rho_bin(idx_negative));
                        end
                        
                    end
                    key.distance_corr_all=distance_corr_all;
                    key.distance_corr_positive=distance_corr_positive;
                    key.distance_corr_negative=distance_corr_negative;
                    key.threshold_for_event = threshold;
                    key.num_svd_components_removed = num_svd_components_removed_vector(i_c);
                    insert(self,key);
                    
                end
            end
            
            
            
            
            
        end
    end
end

