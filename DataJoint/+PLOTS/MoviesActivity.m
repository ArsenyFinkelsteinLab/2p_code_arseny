%{
#
-> EXP2.SessionEpoch
---
%}


classdef MoviesActivity < dj.Computed
    properties
        
        keySource = (EXP2.SessionEpoch- EXP2.SessionEpochSomatotopy) &  IMG.ROI & (IMG.Mesoscope- IMG.Volumetric)  & 'subject_id=464724 OR subject_id=464725';
        
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Lick2D\brain_maps\activity_movies\'];
            video_quality=85;    % Default 75
            speedup_factor=2; %we speed up the movie 10 times relative to the imaging rate
            total_time2plot = 180; % seconds - that's how much imaged time we are going to plot, and we are going to speed this up by speedup_factor
            image_rescaling_factor = 12; % making this number large will make cells larger, making it small will make them smaller
            
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
            %             rel_data_svd = (POP.ROISVD & 'threshold_for_event=0' & 'time_bin=1.5') & rel_roi & key;
            
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
            
            
            %% behavioral trace
            flag_behavior = fetch(IMG.FrameStartTrial  & key);
            if ~isempty(flag_behavior)
                
                rel_predictor_type = (RIDGE.PredictorType&RIDGE.PredictorTypeUse);
                
                rel_start_frame = IMG.FrameStartTrial  & key & RIDGE.Predictors;
                TrialsStartFrame=fetchn(rel_start_frame,'session_epoch_trial_start_frame','ORDER BY trial');
                trial_num=fetchn(rel_start_frame, 'trial','ORDER BY trial');
                
                if isempty(TrialsStartFrame) % not mesoscope recordings
                    rel_start_frame = IMG.FrameStartFile  & key & RIDGE.Predictors;
                    TrialsStartFrame=fetchn(rel_start_frame,'session_epoch_file_start_frame','ORDER BY trial');
                    trial_num=fetchn(rel_start_frame,'trial','ORDER BY trial');
                end
                
                P=struct2table(fetch(RIDGE.Predictors*rel_predictor_type & key,'*','ORDER BY trial'));
                
                idx_frames=[];
                for i_tr = 1:1:numel(trial_num)
                    idx=find(P.trial==trial_num(i_tr),1,'first');
                    TrialsEndFrame = TrialsStartFrame(i_tr) + numel(P.trial_predictor{idx}) - TrialsStartFrame(1);
                    idx_frames = [idx_frames, (TrialsStartFrame(i_tr)- TrialsStartFrame(1)+1):1:TrialsEndFrame];
                end
                
                F = F(:,idx_frames);
                
                Behav_trace(1,:) = 4*cell2mat(fetchn(RIDGE.Predictors & key & 'predictor_name="FirstLickReward"','trial_predictor')');
                Behav_trace(2,:)  = abs(zscore(cell2mat(fetchn(RIDGE.Predictors & key & 'predictor_name="Whiskers"','trial_predictor')')));
                Behav_trace(3,:)  = abs(zscore(cell2mat(fetchn(RIDGE.Predictors & key & 'predictor_name="Jaw"','trial_predictor')')));
                %             Behav_trace(3,:)  = abs(zscore(cell2mat(fetchn(RIDGE.Predictors & key & 'predictor_name="PawFrontLeft"','trial_predictor')')));
                %             Behav_trace(4,:)  = abs(zscore(cell2mat(fetchn(RIDGE.Predictors & key & 'predictor_name="PawFrontRight"','trial_predictor')')));
                Behav_trace(Behav_trace(:)<1.5)=0;
                Behav_trace(Behav_trace(:)>=3)=3;
                
                Behav_trace(1,:)= (4/3)*Behav_trace(1,:);
            end

            
            
            %% Loading ROIs coordinates
            x_all=fetchn(rel_roi,'roi_centroid_x','ORDER BY roi_number');
            y_all=fetchn(rel_roi,'roi_centroid_y','ORDER BY roi_number');
            
            x_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates ,'x_pos_relative','ORDER BY roi_number');
            y_pos_relative=fetchn(rel_roi*IMG.PlaneCoordinates,'y_pos_relative','ORDER BY roi_number');
            
            x_all = x_all + x_pos_relative;
            y_all = y_all + y_pos_relative;
            x_all = x_all/0.75;
            y_all = y_all/0.5;
            
            
            % aligning relative to bregma
            bregma_x_mm=1000*fetchn(IMG.Bregma & key,'bregma_x_cm');
            if ~isempty(bregma_x_mm)
                bregma_y_mm=1000*fetchn(IMG.Bregma & key,'bregma_y_cm');
                x_all_max= max(x_all);
                y_all_min= min(y_all);
                
                x_all=x_all-[x_all_max - bregma_x_mm]; % anterior posterior
                y_all=y_all-y_all_min+bregma_y_mm; % medial lateral
                
            end
            x_all_max = [x_all_max + (3300-max(x_all))]/image_rescaling_factor;
            y_all= y_all +750;
            
            %% Creating a matrix which will display cells as pixels on a 2D matrix according to their anatomical position (cell occupies only one pixel)
            x_all_resized=x_all/image_rescaling_factor; % decreasing the resolution of the matrix
            y_all_resized=y_all/image_rescaling_factor;
            %             MM= zeros(ceil(max(x_all_resized)), ceil(max(y_all_resized))) + 256/2; %setting every pixel which is not a cell into mid of the colormap (white)
            MM= zeros(ceil(x_all_max), ceil(max(y_all_resized))) + 256/2; %setting every pixel which is not a cell into mid of the colormap (white)
            
            
            ind = sub2ind(size(MM),ceil(x_all_resized-min(x_all_resized)+eps),ceil(y_all_resized)); %indices in the matrix that correspond to cells
            
            imaging_frame_rate = fetchn(IMG.FOVEpoch&key,'imaging_frame_rate');
            total_imaging_frames_2use = floor(min(total_time2plot*imaging_frame_rate,size(F,2)));
            
            
            %% Z-scoring
            %             F = zscore(F);
            F = rescale(F);
            F = F-mean(F,2);
            
            min_prctile=0.1;
            max_prctile=97;
            
            %% Looping over PC and creating videos of neural activity weighted by the loadings.
            % We start by creating a movie of the original (non-weighted) neural activity
            num_periods = 10;
            
            max_periods = floor(size(F,2)/total_imaging_frames_2use);
            periods2plot = floor(linspace(1,max_periods,10));
            for i_period = 1:1:num_periods; %numel(components_2plot)
                
                if i_period==1
                    frame2plot_start=1;
                    frame2plot_end = total_imaging_frames_2use;
                else
                    frame2plot_start = periods2plot(i_period-1)*total_imaging_frames_2use + 1;
                    frame2plot_end = frame2plot_start + total_imaging_frames_2use;
                end
                Data2Plot =F(:,frame2plot_start:1:frame2plot_end);
                filename_prefix=['start_' num2str(floor(frame2plot_start/imaging_frame_rate)) 'sec'];
                
                if ~isempty(flag_behavior)
                    
                    Behav_trace_2Plot = Behav_trace(:, frame2plot_start:1:frame2plot_end);
                end
                
                % scaling the colormap
                minp=double(prctile (Data2Plot(:),min_prctile));
                maxp=double(prctile (Data2Plot(:),max_prctile));
                PCT = rescale(Data2Plot,-1,1,'InputMin',minp,'InputMax',maxp);
                imagesc(PCT);
                cmp = inferno(256); % 16 element colormap
                cmp(end,[1 1 1]);
                
                colormap(cmp), colorbar;
                %                 cmp = bluewhitered(256); % 16 element colormap
                %                 colormap(cmp), colorbar;
                Data2Plot_color = uint8(256*mat2gray(double(Data2Plot),[minp,maxp]));
                
                % Creating video file
                myVideo = VideoWriter([dir_current_fig subdir_name '_' filename_prefix '.avi'],'Motion JPEG AVI');
                myVideo.FrameRate = speedup_factor*imaging_frame_rate;
                myVideo.Quality = video_quality;    % Default 75
                open(myVideo);
                
                
                %% PLOT ALLEN MAP
                allen2mm=[1000*3.2/160]/image_rescaling_factor;
                edgeOutline=[];
                if ~isempty(bregma_x_mm)
                    allenDorsalMapSM_Musalletal2019 = load('allenDorsalMapSM_Musalletal2019.mat');
                    edgeOutline = allenDorsalMapSM_Musalletal2019.dorsalMaps.edgeOutline;
                    
                    bregma_x_allen = allenDorsalMapSM_Musalletal2019.dorsalMaps.bregmaScaled(2);
                    bregma_y_allen = allenDorsalMapSM_Musalletal2019.dorsalMaps.bregmaScaled(1);
                end
                %     xlim([min(x),3300]);
                %     %     xlim([min(x),max(x)]);
                %     ylim([0,max(y)]);
                %     set(gca,'Ytick', [0:1000:max(y)])
                
                counter =1;
                Allen_contours2Use=[];
                for i_a = 1:1:numel(edgeOutline)
                    hold on
                    xxx = (-1*([edgeOutline{i_a}(:,1)]-bregma_x_allen))*allen2mm - min(x_all_resized);
                    yyy= ([edgeOutline{i_a}(:,2)]-bregma_y_allen)*allen2mm  ;
                    temp=[];
                    
                    if sum(yyy<0)==0 && sum(xxx<-3000/image_rescaling_factor)==0
                        
                        for i_x=1:1:numel(xxx)
                            temp = [temp xxx(i_x)  (yyy(i_x) + 750/image_rescaling_factor) ];
                        end
                        Allen_contours2Use{counter}=temp;
                        counter =counter +1;
                    end
                    %         plot(0,0  ,'*')
                end
                
                
                % Writing video file
                current2D=MM*0;
                
                B1 =  [0,size(current2D,2)*0.15 ];
                B2 =  [0,size(current2D,2)*0.15 ];
                B3 =  [0,size(current2D,2)*0.15 ];
                %                 B4 =  [0,size(current2D,2)*0.99 ];
                
                for i_fr=1:1:total_imaging_frames_2use
                    current2D(ind) =Data2Plot_color(:,i_fr);
                    RGB = ind2rgb(current2D',cmp);
                    frame_second = (frame2plot_start + i_fr -2)/imaging_frame_rate;
                    
                    %time stamp
                    RGB = insertText(RGB,[size(current2D,1)*0.85,size(current2D,2)*0.8],sprintf('%.1f s',frame_second), 'BoxOpacity', 1);

                    % plot Allen mask
                    for i_a = 1:1:numel(Allen_contours2Use)
                        hold on
                        RGB = insertShape(RGB,'Polygon',Allen_contours2Use{i_a},'Color', [1 1 1], 'LineWidth',1);
                    end
                    
                    % scale bar
                    scalebar_start = (x_all_max*image_rescaling_factor*0.99 - 1000)/image_rescaling_factor;
                    scalebar_end = (x_all_max*image_rescaling_factor*0.99)/image_rescaling_factor;
                    RGB = insertShape(RGB,'Line',[scalebar_start size(current2D,2)*0.99 scalebar_end  size(current2D,2)*0.99],'Color', [1 1 1], 'LineWidth',1);
                    RGB = insertText(RGB,[scalebar_start*1.05 ,size(current2D,2)*0.9],'1 mm', 'BoxColor', [0 0 0], 'BoxOpacity', 0, 'TextColor',[1 1 1]);
                    %                     scalebar_start = (x_all_max*image_rescaling_factor*0.95 - 1000)/image_rescaling_factor;
                    %                     scalebar_end = (x_all_max*image_rescaling_factor*0.95)/image_rescaling_factor;
                    %                     RGB = insertShape(RGB,'Line',[scalebar_start size(current2D,2)*0.95 scalebar_end  size(current2D,2)*0.95],'Color', [1 1 1], 'LineWidth',1);
                    %                     RGB = insertText(RGB,[scalebar_start*1.05 ,size(current2D,2)*0.85],'1 mm', 'BoxColor', [0 0 0], 'BoxOpacity', 0, 'TextColor',[1 1 1]);
                    
                    
                    if ~isempty(flag_behavior)
                        
                        % behavioral trace - reward
                        temp1 = -Behav_trace_2Plot(1,i_fr)*15 + size(current2D,2)*0.15;
                        B1= [B1  i_fr*(size(current2D,1)/total_imaging_frames_2use) temp1 ];
                        RGB = insertShape(RGB,'Line',B1,'Color', [1 0.25 0.25], 'LineWidth',1);
                        
                        % behavioral trace 0 whiskers
                        temp1 = -Behav_trace_2Plot(2,i_fr)*15 + size(current2D,2)*0.15;
                        B2= [B2  i_fr*(size(current2D,1)/total_imaging_frames_2use) temp1 ];
                        RGB = insertShape(RGB,'Line',B2,'Color', [0.25 0.25 1], 'LineWidth',1);
                        
                        
                        % behavioral trace - jaw
                        temp1 = -Behav_trace_2Plot(3, i_fr)*15 + size(current2D,2)*0.15;
                        B3= [B3  i_fr*(size(current2D,1)/total_imaging_frames_2use) temp1 ];
                        RGB = insertShape(RGB,'Line',B3,'Color', [0.5 1 0.5], 'LineWidth',1);
                        
                        
                        %                        % behavioral trace - paw right
                        %                     temp1 = -Behav_trace_2Plot(4,i_fr)*10 + size(current2D,2)*0.2;
                        %                     B4= [B4  i_fr*(size(current2D,1)/total_imaging_frames_2use) temp1 ];
                        %                     RGB = insertShape(RGB,'Line',B4,'Color', [0.25 0.25 0.25], 'LineWidth',1);
                        
                    end
                    
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