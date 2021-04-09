%{
# Take the closest neuron within a small radius around the photostimulation site and assess its response, sites that are too far from cells won't appear here
-> IMG.PhotostimGroup
-> IMG.ROI
---
response_mean_trials        : blob                # response amlitude (mean over response window) at each trial
response_peak_trials        : blob                # response amlitude (peak at response window) at each trial
response_trace_trials  : longblob          # response trace at each trial
time_vector            : blob                # response amlitude at each trial
%}


classdef ROIResponseDirectVariability < dj.Imported
    properties
        %         keySource = IMG.PhotostimGroup;
        keySource = EXP2.SessionEpoch & 'flag_photostim_epoch =1' & (IMG.FOV & STIM.ROIInfluence5) & IMG.Volumetric;
    end
    methods(Access=protected)
        function makeTuples(self, key)
            
            flag_baseline_trial_or_avg=2; %0 - baseline averaged across trials, 1 baseline per trial, 2 global baseline - mean of roi across the entire session epoch
            
            
            % frame_window_short=[40,40]/4;
            % frame_window_long=[200,100]/2;
            % frame_window_short=[40,40];
            % frame_window_long=[100,200];
            smooth_bins=1; %2
            
            
            
            try
                frame_rate= fetch1(IMG.FOVEpoch & key, 'imaging_frame_rate');
            catch
                frame_rate= fetch1(IMG.FOV & key, 'imaging_frame_rate');
            end
            
            %             timewind_stim=[0.25,1.5];
            % timewind_baseline=[0.25,1.5]-10;
            % timewind_baseline = [-15,-5];
            % time  = [-20: (1/frame_rate): 10];
            
            %             timewind_baseline = [-5,0];
            time  = [-5: (1/frame_rate): 11];
            
            
            
            
            G=fetch(IMG.PhotostimGroupROI & STIM.ROIResponseDirect & key,'*');
            
            
            
            roi_list_direct=[G.roi_number];
            
            
            
            for i_g=1:1:numel(roi_list_direct)
                key.photostim_group_num = G(i_g).photostim_group_num;
                
                k1=key;
                k1.roi_number = roi_list_direct(i_g);
                
                
                
                
                f_trace = fetch1(IMG.ROITrace & k1,'f_trace');
                photostim_start_frame = fetch1(IMG.PhotostimGroup &  STIM.ROIResponseDirect & k1,'photostim_start_frame');
                %         global_baseline=mean(movmin(f_trace_direct(i_epoch,:),1009));
                global_baseline=mean( f_trace);
                
                %                 timewind_response = [ 0 2];
                timewind_response = [ 0 2];
                timewind_baseline1 = [ -5 0];
                timewind_baseline2  = [-5 0] ;
                timewind_baseline3  = [ -5 0];
                [StimStat,StimTrace] = fn_compute_photostim_response_variability (f_trace , photostim_start_frame, timewind_response, timewind_baseline1,timewind_baseline2,timewind_baseline3, flag_baseline_trial_or_avg, global_baseline, time);
                
                
                kk = fetch( STIM.ROIResponseDirect & key);
                kk.response_mean_trials = StimStat.response_trials;
                kk.response_peak_trials = StimStat.response_peak_trials;
                kk.response_trace_trials = StimTrace.response_trace_trials;
                kk.time_vector = time;
                insert(self, kk); %
                
                
            end
        end
    end
end