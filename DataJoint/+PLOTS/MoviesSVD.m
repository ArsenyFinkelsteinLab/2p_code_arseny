%{
#
-> EXP2.SessionEpoch
---
%}


classdef MoviesSVD < dj.Computed
    properties
        
        keySource = EXP2.SessionEpoch &  POP.ROISVD & (IMG.Mesoscope- IMG.Volumetric) - EXP2.SessionEpochSomatotopy;
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\SVD_movies\'];
            video_quality=75;    % Default 75
            speedup_factor=3; %we speed up the movie 10 times relative to the imaging rate
            total_time2plot = 360; % seconds - that's how much imaged time we are going to plot, and we are going to speed this up by speedup_factor
            image_rescaling_factor = 15; % making this number large will make cells larger, making it small will make them smaller
            
            % saving each session epoch into a separate folder
            session_date = fetch1(EXP2.Session & key,'session_date');
            session_epoch_number = fetch1(EXP2.SessionEpoch & key,'session_epoch_number'); 
            session_epoch_type = fetch1(EXP2.SessionEpoch & key,'session_epoch_type'); 
            subdir_name = sprintf('anm%d_s%d_%s_e%d_%s',key.subject_id,key.session, session_date, session_epoch_number, session_epoch_type);
            dir_current_fig = [dir_current_fig  subdir_name '\']; 
            if isempty(dir(dir_current_fig))
                mkdir (dir_current_fig)
            end
            
            rel_roi = (IMG.ROI - IMG.ROIBad) & key;
            rel_data = IMG.ROIdeltaF & rel_roi & key;
            rel_data_svd = (POP.ROISVD & 'threshold_for_event=0' & 'time_bin=1.5') & rel_roi & key;
            
            %% loading traces
            roi_list=fetchn(rel_roi & key,'roi_number','ORDER BY roi_number');
            num_rois=numel(roi_list);
            chunk_size=500;
            counter=0;
            for i_chunk=1:chunk_size:roi_list(end)
                roi_interval = [i_chunk, i_chunk+chunk_size];
                try
                    temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'dff_trace','ORDER BY roi_number'));
                catch
                    temp_F=cell2mat(fetchn(rel_data & key & sprintf('roi_number>=%d',roi_interval(1)) & sprintf('roi_number<%d',roi_interval(2)),'spikes_trace','ORDER BY roi_number'));
                end
                temp_count=(counter+1):1: (counter + size(temp_F,1));
                F(temp_count,:)=temp_F;
                counter = counter + size(temp_F,1);
            end
            
            %% Z-scoring
            F = zscore(F);
            
            %% Loading SVD weights
            ROI_WEIGHTS=cell2mat(fetchn(rel_data_svd,'roi_components','ORDER BY roi_number'));
            max_components = size(ROI_WEIGHTS,2);
            components_2plot = [1:10,50, 100, max_components];
            components_2plot(components_2plot>max_components)=[];
            
            %% Loading ROIs coordinates
            x_all=fetchn(rel_roi,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(rel_roi,'roi_centroid_y','ORDER BY roi_number');
            
            x_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates ,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative;
            y_all = y_all + y_pos_relative;
            x_all = x_all/0.75;
            y_all = y_all/0.5;
            
            %% Creating a matrix which will display cells as pixels on a 2D matrix according to their anatomical position (cell occupies only one pixel)
            x_all_resized=x_all/image_rescaling_factor; % decreasing the resolution of the matrix
            y_all_resized=y_all/image_rescaling_factor;
            MM= zeros(ceil(max(x_all_resized)), ceil(max(y_all_resized))) + 256/2; %setting every pixel which is not a cell into mid of the colormap (white)
            ind = sub2ind(size(MM),ceil(x_all_resized),ceil(y_all_resized)); %indices in the matrix that correspond to cells
            
           imaging_frame_rate = fetchn(IMG.FOVEpoch&key,'imaging_frame_rate');
           total_imaging_frames_2use = floor(min(total_time2plot*imaging_frame_rate,size(F,2)));
            F = F(:,1:1:total_imaging_frames_2use);
            
            %% Looping over PC and creating videos of neural activity weighted by the loadings.
            % We start by creating a movie of the original (non-weighted) neural activity
            
            for i_pc = 0:1:numel(components_2plot)
                
                if i_pc==0
                    Data2Plot = F; %F./max(F,[],2);
                    filename_prefix='original';
                    min_prctile=1;
                    max_prctile=95;

                else
                    Data2Plot = F.*ROI_WEIGHTS(:,components_2plot(i_pc));
                    filename_prefix=['pc' num2str(components_2plot(i_pc))];
                    min_prctile=1;
                    max_prctile=99;

                end
                
                % scaling the colormap
                minp=double(prctile (Data2Plot(:),min_prctile));
                maxp=double(prctile (Data2Plot(:),max_prctile));
                PCT = rescale(Data2Plot,-1,1,'InputMin',minp,'InputMax',maxp);
                imagesc(PCT);
                cmp = bluewhitered(256); % 16 element colormap
                colormap(bluewhitered(256)), colorbar;
                Data2Plot_color = uint8(256*mat2gray(double(Data2Plot),[minp,maxp]));
                
                % Creating video file
                myVideo = VideoWriter([dir_current_fig subdir_name '_' filename_prefix '.avi'],'Motion JPEG AVI');
                myVideo.FrameRate = speedup_factor*imaging_frame_rate;
                myVideo.Quality = video_quality;    % Default 75
                open(myVideo);
                
                % Writing video file
                current2D=MM;
                for i_fr=1:1:total_imaging_frames_2use
                    current2D(ind) =Data2Plot_color(:,i_fr);
                    RGB = ind2rgb(current2D',cmp);
                    writeVideo(myVideo, RGB);
                end
                close(myVideo);
                
                % displaying the movie
                %         for i=1:1:size(PCxTime,2)
                %             MM(ind) = PCxTime(:,i);
                %             imagesc(MM')
                %             set(gca,'CLim',[min(PCxTime(:))/10 max(PCxTime(:))/10])
                %             colormap(bluewhitered);
                %             pause(0.01)
                %         end
            end
            insert(self,key);
        end
    end
end