function create_movies_activity
close all
dir_save_fig_base = ['Z:\users\Arseny\Projects\Learning\imaging2p\Results\Movies\' 'anm' '\'];


blank_percentile=10; % blanking dark spots in the video (for display in movies only, not for savign in DJ)
smoothing_3D_size=3; %in x-y pixel and time(z) (for display in movies only, not for savign in DJ)
video_quality=50;

sessions = unique(fetchn(IMG.FOVRegisteredMovie,'session'));

for i_s = 1:1:numel(sessions)
    k=[];
    
    k.session = sessions(i_s);
    subject_id = unique(fetchn(IMG.FOVRegisteredMovie & k,'subject_id'));
    dir_save_fig = [dir_save_fig_base num2str(subject_id) '\'];

    outcomes=unique(fetchn(IMG.FOVRegisteredMovie & k,'outcome'));
    trial_type_names=unique(fetchn(IMG.FOVRegisteredMovie & k,'trial_type_name'));
    for i_o=1:1:numel(outcomes)
        for i_tr_types=1:1:numel(trial_type_names)
            k.outcome = outcomes{i_o};
            k.trial_type_name = trial_type_names{i_tr_types};
            
            M_avg = fetchn(IMG.FOVRegisteredMovieFrame & k,'fov_movie_trial_avg','ORDER BY movie_frame_number');
            frame_rate = fetch1(IMG.FOVRegisteredMovie & k,'movie_frame_rate');
            
            filename_prefix = ['s' num2str(k.session) '_' k.trial_type_name '_' k.outcome];

            % saving videos f and deltaf/f
            fn_save_movies_fov (M_avg,blank_percentile, smoothing_3D_size, video_quality, frame_rate, dir_save_fig_base, filename_prefix)
            
            %saving slowed down videos
            dir_save_fig_base = [dir_save_fig_base '\slow5X\'];
            fn_save_movies_fov (M_avg,blank_percentile, smoothing_3D_size, video_quality, frame_rate/5, dir_save_fig_base, filename_prefix)
            
        end
    end
end
end