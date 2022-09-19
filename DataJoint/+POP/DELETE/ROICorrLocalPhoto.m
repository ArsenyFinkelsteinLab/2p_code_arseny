%{
# Local correlation
-> EXP2.SessionEpoch
-> IMG.ROI
radius_size                   : float                               # radius size, in um in lateral dimension
num_svd_components_removed      : int     # how many of the first svd components were removed
---
corr_local=null   : float                                           # trace (dff or spikes) correlation between a given cell (seed) and all of its neihgbors within radius_size
corr_local_without_inner_ring : float                              # same as above, but ecxluding neurons within min_lateral_distanceb from the seed .   DEBUG: in the future add null option to this field

num_neurons_in_radius =null   : float                               # number of neurons within radius_size from the seed
num_neurons_in_radius_without_inner_ring =null   : float           # number of neurons within radius size, exluding neurons within min_lateral_distanceb from the seed

%}


classdef ROICorrLocalPhoto < dj.Computed
    properties
        keySource = EXP2.SessionEpoch  & IMG.ROI & IMG.ROISpikes & (EXP2.Session & STIM.ROIResponseDirect) & IMG.Volumetric;
    end
    methods(Access=protected)
        function makeTuples(self, key)
           
            num_svd_components_removed_vector = [0, 1 , 10,  100];

            time_bin=1; %s
            min_lateral_distance =25;
            
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            rel_data = IMG.ROISpikes & rel_roi & key;
            
            %             radius_size_vector=[25,50,75,100, 125, 150, 175, 200];
            radius_size_vector=[50,100,200];
            
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            zoom =fetch1(IMG.FOVEpoch & key,'zoom');
            kkk.scanimage_zoom = zoom;
            pix2dist=  fetch1(IMG.Zoom2Microns & kkk,'fov_microns_size_x') / fetch1(IMG.FOV & key, 'fov_x_size');
            
            
            
            key_ROI=fetch(rel_roi,'ORDER BY roi_number');
            
            x_all=fetchn(rel_roi,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(rel_roi,'roi_centroid_y','ORDER BY roi_number');
            
            x_all = x_all * pix2dist;
            y_all = y_all * pix2dist;
            
            
            try
                F_original = fetchn(rel_data ,'dff_trace','ORDER BY roi_number');
            catch
                F_original = fetchn(rel_data ,'spikes_trace','ORDER BY roi_number');
            end
            F_original=cell2mat(F_original);
            
            if time_bin>0
                bin_size_in_frame=ceil(time_bin*frame_rate);
                bins_vector=1:bin_size_in_frame:size(F_original,2);
                bins_vector=bins_vector(2:1:end);
                for  i= 1:1:numel(bins_vector)
                    ix1=(bins_vector(i)-bin_size_in_frame):1:(bins_vector(i)-1);
                    F_binned(:,i)=mean(F_original(:,ix1),2);
                end
            else
                F_binned=F_original;
            end

            clear F_original
            
            F_binned = gpuArray((F_binned));
            %             F_binned = F_binned-mean(F_binned,2);
            F_binned=zscore(F_binned,[],2);
            [U,S,V]=svd(F_binned); % S time X neurons; 
            
            
            for i_c = 1:1:numel(num_svd_components_removed_vector)
                key.num_svd_components_removed=num_svd_components_removed_vector(i_c);
                if num_svd_components_removed_vector(i_c)>0
                    num_comp = num_svd_components_removed_vector(i_c);
                    F = U(:,(1+num_comp):end)*S((1+num_comp):end, (1+num_comp):end)*V(:,(1+num_comp):end)';
                else
                    F=F_binned;
                end
                F=gather(F);
                
                
                for ir = 1:1:numel(radius_size_vector)
                    fn_local_correlations_space(key, key_ROI,F,x_all, y_all, radius_size_vector(ir), self, min_lateral_distance )
                end
            end
        end
    end
end



