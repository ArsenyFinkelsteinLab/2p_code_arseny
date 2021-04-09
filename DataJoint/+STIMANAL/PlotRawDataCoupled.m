%{
# Photostim Group
-> EXP2.SessionEpoch
%}


classdef PlotRawDataCoupled < dj.Imported
    properties
        keySource = (EXP2.SessionEpoch & 'flag_photostim_epoch =1' & IMG.ROI & STIM.ROIResponseDirect) &  (STIMANAL.SessionEpochsIncluded & 'stimpower_percent=15' & 'flag_include=1' & (STIMANAL.NeuronOrControl & 'neurons_or_control=1' & 'num_targets>30'));
    end
    methods(Access=protected)
        function makeTuples(self, key)
            flag_coupled_or_direct=1; % 1 direct, 0 coupled
            flag_coupled_or_direct_label = {'direct','coupled'};

            
            dir_base = fetch1(IMG.Parameters & 'parameter_name="dir_root_save"', 'parameter_value');
            dir_current_fig = [dir_base  '\Photostim\photostim_traces_DJ\' flag_coupled_or_direct_label{flag_coupled_or_direct} '\'];
                      

            close all
            %Graphics
            %---------------------------------
            figure;
            set(gcf,'DefaultAxesFontName','helvetica');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 23 30]);
            set(gcf,'PaperOrientation','portrait');
            set(gcf,'Units','centimeters','Position',get(gcf,'paperPosition')+[3 0 0 0]);
            set(gcf,'color',[1 1 1]);
            
            
            
            
            session_date = fetch1(EXP2.Session & key,'session_date');
            dir_current_fig = [dir_current_fig '\anm' num2str(key.subject_id) '\session' num2str(key.session) '_' session_date '_' 'session_epoch' num2str(key.session_epoch_number) '\'];
            if isempty(dir(dir_current_fig))
                mkdir (dir_current_fig)
            end
            
            frame_rate=fetch1(IMG.FOVEpoch&key,'imaging_frame_rate');
            roi_list=fetchn((IMG.ROI-IMG.ROIBad)   & key,'roi_number','ORDER BY roi_number');
            
            neuron_or_control_flag = [1,0];
            neuron_or_control_label={'Neuron','Control'};
            for i_n = 1:1:numel(neuron_or_control_flag)
                 kk.neurons_or_control = neuron_or_control_flag(i_n);
                 rel_direct= IMG.PhotostimGroup & (STIMANAL.NeuronOrControl & kk & key);

                
                
                F_original=cell2mat([fetchn(IMG.ROIdeltaF & key, 'dff_trace')]);
                time  = [1:1:size(F_original,2)]/frame_rate;
                
                time_bin=1;
                F_binned=[];
                if time_bin>0
                    bin_size_in_frame=ceil(time_bin*frame_rate);
                    bins_vector=1:bin_size_in_frame:size(F_original,2);
                    bins_vector=bins_vector(2:1:end);
                    for  i_neuron= 1:1:numel(bins_vector)
                        ix1=(bins_vector(i_neuron)-bin_size_in_frame):1:(bins_vector(i_neuron)-1);
                        F_binned(:,i_neuron)=mean(F_original(:,ix1),2);
                    end
                    time = time(1:bin_size_in_frame:end);
                else
                    F_binned=F_original;
                end
                
                
                F_binned = gpuArray((F_binned));
%                 F_binned = F_binned-mean(F_binned,2);
                F_binned=zscore(F_binned,[],2);
                [U,S,V]=svd(F_binned); % S time X neurons; % U time X time;  V neurons x neurons
                num_svd_components_removed_vector=[0,1,10];
                
                F=[];
                
                keykey.num_svd_components_removed=1;
                if  flag_coupled_or_direct==1
                    rel_data = STIM.ROIResponseDirect & keykey & rel_direct;
                elseif  flag_coupled_or_direct==0
                    rel_coupled = STIM.ROIResponseZscore & keykey & rel_direct & 'response_p_value1_odd<=1' &  'response_distance_lateral_um>20';
                end

                RESPONSE=fetch(rel_data & keykey);

                for i_c = 1:1:numel(num_svd_components_removed_vector)
                    keykey.num_svd_components_removed= num_svd_components_removed_vector(i_c);
                    
                    if num_svd_components_removed_vector(i_c)>0
                        num_comp = num_svd_components_removed_vector(i_c);
                        Ftemp = U(:,(1+num_comp):end)*S((1+num_comp):end, (1+num_comp):end)*V(:,(1+num_comp):end)';
                    else
                        Ftemp=F_binned;
                    end
                    %                         F = zscore(F,[],2); % note that we zscore after perofrming SVD
                    F{i_c}=gather(Ftemp);
                    
                end
                
                for i_neuron=1:1:(numel(RESPONSE))
                    clf
                    photostim_start_frame=fetch1(IMG.PhotostimGroup	 & RESPONSE(i_neuron), 'photostim_start_frame');
                    photostim_start_frame=ceil(photostim_start_frame./bin_size_in_frame);
                    
                    photostim_start_frame=photostim_start_frame(1:end-2);
                    
                    
                    for i_c = 1:1:numel(num_svd_components_removed_vector)
                        key_current_coupled = RESPONSE(i_neuron);
                        key_current_coupled.num_svd_components_removed= num_svd_components_removed_vector(i_c);
                        CURRENT_COUPLED= fetch(STIM.ROIResponseZscore & key_current_coupled,'*');
                        
                        subplot(2,3,i_c)
                        idx_roi = roi_list==RESPONSE(i_neuron).roi_number;
                        f=F{i_c}(idx_roi,:);
                        hold on
                        time=time(1:1:numel(f));
                        plot(f,'-b')
%                         plot(photostim_start_frame,f(photostim_start_frame),'or')
                        plot(photostim_start_frame+1,f(photostim_start_frame+1),'or')
                        %                         title(sprintf('mean response to stimulation %.2f',mean(f(photostim_start_frame+1))));
                        
                        if i_c==1
                            title(sprintf('Lateral dist. %.1f\nAxial dist. %.1f \nSVD removed %d',CURRENT_COUPLED.response_distance_lateral_um,CURRENT_COUPLED.response_distance_axial_um, num_svd_components_removed_vector(i_c)));
                        elseif i_c==2
                            title(sprintf('                 Target: %s Group %d ROI %d\n  anm%d session%d epoch%d %s \nSVD removed %d',neuron_or_control_label{i_n},RESPONSE(i_neuron).photostim_group_num,RESPONSE(i_neuron).roi_number, key.subject_id,key.session, key.session_epoch_number,session_date, num_svd_components_removed_vector(i_c)));
                        elseif i_c>2
                            title(sprintf('\n\nSVD removed %d',num_svd_components_removed_vector(i_c)));
                        end
                        
                        xlabel('Frames');
                        ylabel('DFF');
                        
                        time_interval  = [-30: (1/frame_rate): 30];
                        time_interval = time_interval(1:bin_size_in_frame:end);
                        Ftrials=[];
                        counter=0;
                        num_frames_pre =  sum(time_interval<0);
                        num_frames_post =  sum(time_interval>0);
                        idx_include=[];
                        for i_stim=1:1:numel(photostim_start_frame)
                            s_fr = photostim_start_frame(i_stim);
                            if  (s_fr-num_frames_pre)>0 && (s_fr+num_frames_post)<=length(f) % if the time window is within the full trace
                                counter = counter+1;
                                Ftrials(counter,:)=f(s_fr- num_frames_pre :1:s_fr+num_frames_post-1);
                            end
                        end
                        idx_include=1:1:counter;
                        idx_include_odd = idx_include(1:2:end);
                        idx_include_even= idx_include(2:2:end);
                        
                        subplot(2,3,i_c+3)
                        hold on
                        shadedErrorBar(time_interval,mean(Ftrials(idx_include_odd,:),1),std(Ftrials(idx_include_odd,:),1)./sqrt(numel(idx_include_odd)),'lineprops',{'-','Color',[0 0 0]})
                        shadedErrorBar(time_interval,mean(Ftrials(idx_include_even,:),1),std(Ftrials(idx_include_even,:),1)./sqrt(numel(idx_include_even)),'lineprops',{'-','Color',[1 0 0]})
                        title(sprintf('odd pval %.5f \neven pval %.5f',CURRENT_COUPLED.response_p_value2_odd , CURRENT_COUPLED.response_p_value2_even));
                        xlim([-30,30])
                        xlabel('Time (s)');
                        ylabel('DFF');
                        
                    end
                   
                    %
                    filename=[neuron_or_control_label{i_n} '_photostim_group_' num2str(RESPONSE(i_neuron).photostim_group_num) 'roi_' num2str(RESPONSE(i_neuron).roi_number)];
                    figure_name_out=[ dir_current_fig filename];
                    eval(['print ', figure_name_out, ' -dtiff  -r100']);
                    % eval(['print ', figure_name_out, ' -dpdf -r200']);
                    
                    clf;
                    
                    
                end
            end
            
            
            
            
            insert(self,key);
            
        end
    end
end
