%{
# Photostim Group
-> EXP2.SessionEpoch
num_svd_components_removed                  : int     # how many of the first svd components were removed
neurons_or_control     :boolean              # 1 - neurons, 0 control
%}


classdef PLOTInfluenceTrace < dj.Imported
    properties
        %         keySource = (EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & STIMANAL.NeuronOrControl & STIM.ROIResponseTraceZscore3) & (STIMANAL.SessionEpochsIncluded& IMG.PlaneCoordinates & 'stimpower_percent=15' & 'flag_include=1' & (STIMANAL.NeuronOrControl & 'neurons_or_control=1' & 'num_targets>30'));
        %             keySource = (EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & STIMANAL.NeuronOrControl & STIM.ROIResponseTraceZscore3);
        keySource= (EXP2.SessionEpoch & STIM.ROIInfluenceTrace2) & (IMG.FOVEpoch & 'imaging_frame_rate>5.2') &  (STIMANAL.SessionEpochsIncluded& IMG.PlaneCoordinates & 'stimpower_percent=15' & 'flag_include=1' & 'session_epoch_number<=3' ...
    & (STIMANAL.NeuronOrControl & 'neurons_or_control=1' & 'num_targets>=30') ...
    & (STIMANAL.NeuronOrControl & 'neurons_or_control=0' & 'num_targets>=30'))
    end
    methods(Access=protected)
        function makeTuples(self, key)
             
                              rel_data=STIM.ROIInfluenceTrace2;

            time_bin=0.5; %s
            
            flag_session_by_session = 0; %1 per session, 0 all sessions combined
            flag_mean_over_std = 0; %1 normalize each trace by this cell std, 0 not
            
            
          

            num_svd_components_removed_vector = [0, 1];
            neurons_or_control_flag = [0,1];
            flag_distance = [0,1,2,3]; % 0 (0-25um), 1 (25-100um), 2 (100-200um), 3 (>200 um)
            flag_distance_label = {'distance 25um <', '25um <= distance < 100um', '100um <= distance < 200um', 'distance >= 200um'};
            
            k_trace.response_p_val =1;  % p_val=[0.01, 0.05, 1]
            k_trace.response_sign = 'all'; %all excited inhibited
            
            
            
            clf
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate = fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
           
              if flag_session_by_session==0
                  key=[];
%                       rel_sessions= (EXP2.SessionEpoch & ...
%                       (IMG.FOVEpoch & 'imaging_frame_rate>5.2')  ...
%                       &  (STIMANAL.SessionEpochsIncluded& IMG.PlaneCoordinates & 'stimpower_percent=15' & 'flag_include=1' & 'session_epoch_number<=3' ...
%                       & (STIMANAL.NeuronOrControl & 'neurons_or_control=1' & 'num_targets>=30') ...
%                       & (STIMANAL.NeuronOrControl & 'neurons_or_control=0' & 'num_targets>=30')));


                rel_sessions= (EXP2.SessionEpoch & ...
                    (IMG.FOVEpoch & 'imaging_frame_rate>5.2'));


              else
                  rel_sessions=[];
              end
            

            
            
            time  = [-10: (1/frame_rate): 10];
            bin_size_in_frame=ceil(time_bin*frame_rate);
            time = time(1:bin_size_in_frame:end);
            
            
            for i_c = 1:1:numel(num_svd_components_removed_vector)
                k_trace.num_svd_components_removed = num_svd_components_removed_vector(i_c);
                
                for i_distance = 1:1: numel(flag_distance)
                    k_trace.flag_distance=flag_distance(i_distance);
                    column_plot_offset =4*(i_distance -1);
                    MEAN{1}=zeros(2,numel(time))+NaN;
                    MEAN{2}=zeros(2,numel(time))+NaN;
                    
                    
                    STEM{1}=zeros(2,numel(time))+NaN;
                    STEM{2}=zeros(2,numel(time))+NaN;
                    
                    
                    for i_n = 1:1:numel(neurons_or_control_flag)
                        k.neurons_or_control=neurons_or_control_flag(i_n);
                        rel_direct= IMG.PhotostimGroup & (STIMANAL.NeuronOrControl & k) & key;
                        
                        rel_fetch = (rel_data& k_trace) & rel_direct & key  & 'num_pairs>1';
                        rel_fetch = rel_fetch & rel_sessions;
                        if rel_fetch.count()>0
                            num_pairs=fetchn(rel_fetch,'num_pairs', 'ORDER BY photostim_group_num');
                            
                            %                             % 1st half trials
                            %                             r=cell2mat(fetchn(rel_fetch,'response_trace_mean_1half', 'ORDER BY photostim_group_num'));
                            %                             r=r.*(num_pairs/(mean(num_pairs)));
                            %                             MEAN{1}(i_n,:)=nanmean(r,1);
                            %                             STEM{1}(i_n,:)=nanstd(r,1)./sqrt(numel(num_pairs));
                            %
                            %                             % 2nd half trials
                            %                             r=cell2mat(fetchn(rel_fetch,'response_trace_mean_2half', 'ORDER BY photostim_group_num'));
                            %                             r=r.*(num_pairs/(mean(num_pairs)));
                            %                             MEAN{2}(i_n,:)=nanmean(r,1);
                            %                             STEM{2}(i_n,:)=nanstd(r,1)./sqrt(numel(num_pairs));
                            
                            % odd trials
                            if flag_mean_over_std==0
                                r=cell2mat(fetchn(rel_fetch,'response_trace_mean_odd', 'ORDER BY photostim_group_num'));
                            elseif flag_mean_over_std==1
                                r=cell2mat(fetchn(rel_fetch,'response_trace_mean_over_std_odd', 'ORDER BY photostim_group_num'));
                            end
                            r=(r./num_pairs).*(num_pairs/mean(num_pairs));
                            MEAN{1}(i_n,:)=nanmean(r,1);
                            STEM{1}(i_n,:)=nanstd(r,[],1)./sqrt(numel(num_pairs));
                            
                            % even trials
                            if flag_mean_over_std==0
                                r=cell2mat(fetchn(rel_fetch,'response_trace_mean_even', 'ORDER BY photostim_group_num'));
                            elseif flag_mean_over_std==1
                                r=cell2mat(fetchn(rel_fetch,'response_trace_mean_over_std_even', 'ORDER BY photostim_group_num'));
                            end
                            r=(r./num_pairs).*(num_pairs/mean(num_pairs));
                            MEAN{2}(i_n,:)=nanmean(r,1);
                            STEM{2}(i_n,:)=nanstd(r,[],1)./sqrt(numel(num_pairs));
                            
                        else
                            continue
                    end
                        
                end
                subplot(4,4,i_c+column_plot_offset)
                hold on
                shadedErrorBar(time,MEAN{2}(1,:),STEM{2}(1,:),'lineprops',{'-','Color',[0 0 0]})
                shadedErrorBar(time,MEAN{2}(2,:),STEM{2}(2,:),'lineprops',{'-','Color',[1 0 0]})
                xlabel('Time from photostim. (s)');
                ylabel('Influence, z-score')
                title(sprintf('%s\n             SVD comp. removed: %d',flag_distance_label{flag_distance(i_distance)+1}, num_svd_components_removed_vector(i_c)));
                xlim([-10 10])
            end
        end
        insert(self,key)
    end
end
end