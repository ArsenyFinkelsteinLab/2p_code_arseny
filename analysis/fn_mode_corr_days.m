function fn_mode_corr_days(key, first_date, dir_save_figure)

k=key;
k.session_date=first_date;

k=fetch(EXP.Session & k);
key.multiple_sessions_uid = fetchn(IMG.FOVmultiSessions & k,'multiple_sessions_uid');

session = fetchn(IMG.FOVmultiSessions & key, 'session', 'ORDER BY session');

mode_names= {'LateDelay','Movement','Ramping'};
for i_m = 1:1:numel (mode_names)
    w=[];
    for i_s =1:1:numel(session)
        key.session = session(i_s);
        key.mode_type_name = mode_names{i_m}
%         w(:,i_s)=fetchn(ANLI.Mode & key & ANLI.IncludeROImultiSession,'mode_unit_weight', 'ORDER BY roi_number')
%                 w(:,i_s)=fetchn(ANLI.Mode & key , 'mode_unit_weight', 'ORDER BY roi_number')
                w(:,i_s)=fetchn((ANLI.Mode& ANLI.IncludeROImultiSession2intersect) & key ,'mode_unit_weight', 'ORDER BY roi_number');

    end
    
%     w(w>0)=1;
%     w(w<=0)=-1;

    r=corr(w, 'rows', 'pairwise');
    
    subplot(2,2,i_m)
    diag_nan=[1:1:size(r,1)]+NaN;
    diag_m = diag(diag_nan,0);
    imagescnan(r+diag_m,[0 1]);
    colormap(jet);
    colorbar;
    title(sprintf('%s Mode',mode_names{i_m}));
end

dir_save_figure = [dir_save_figure '\'];
if isempty(dir(dir_save_figure))
    mkdir (dir_save_figure)
end

filename=['from' first_date ];
figure_name_out=[ dir_save_figure filename];
eval(['print ', figure_name_out, ' -dtiff -cmyk -r200']);
clf;
