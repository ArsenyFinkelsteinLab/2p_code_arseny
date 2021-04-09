function fn_mode_cluster_corr_days(key, first_date, dir_save_figure)

k=key;
k.session_date=first_date;

k=fetch(EXP.Session & k);
key.multiple_sessions_uid = fetchn(IMG.FOVmultiSessions & k,'multiple_sessions_uid');

session = fetchn(IMG.FOVmultiSessions & key, 'session', 'ORDER BY session');

trial_name_list ={'l','r'};
epoch_list=fetchn(ANLI.EpochName,'trial_epoch_name');
counter=0;
for i_tname =1:1:numel(trial_name_list)
    for i_e =1:1:numel(epoch_list)
        w=[];
        for i_s =1:1:numel(session)
            key.session = session(i_s);
            key.trial_type_name = trial_name_list{i_tname};
            key.trial_epoch_name = epoch_list{i_e};
            %         w(:,i_s)=fetchn(ANLI.Mode & key & ANLI.IncludeROImultiSession,'mode_unit_weight', 'ORDER BY roi_number')
            %                 w(:,i_s)=fetchn(ANLI.Mode & key , 'mode_unit_weight', 'ORDER BY roi_number')
            w(:,i_s)=abs(fetchn((ANLI.ModeClustering & ANLI.IncludeROImultiSession2intersect) & key ,'mode_unit_weight', 'ORDER BY roi_number'));
        end
        counter=counter+1;
        
        r=corr(w, 'rows', 'pairwise');
        
        subplot(2,2,counter)
        diag_nan=[1:1:size(r,1)]+NaN;
        diag_m = diag(diag_nan,0);
        imagescnan(r+diag_m,[0 1]);
        colormap(jet);
        colorbar;
                title(sprintf('Clustering based\n on %s, lick %s',epoch_list{i_e},trial_name_list{i_tname}));
    end
end

dir_save_figure = [dir_save_figure '\'];
if isempty(dir(dir_save_figure))
    mkdir (dir_save_figure)
end

filename=['from' first_date ];
figure_name_out=[ dir_save_figure filename];
eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
clf;
