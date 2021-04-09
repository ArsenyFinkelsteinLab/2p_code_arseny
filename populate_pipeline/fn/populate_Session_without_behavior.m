function populate_Session_without_behavior (user_name, rig)
close all;

dir_data = fetch1(IMG.Parameters & 'parameter_name="dir_raw_data_scan_image"','parameter_value');

%% Insert/Populate Sessions and dependent tables
temp = dir(dir_data); %gets  the names of all files and nested directories in this folder
DirNames = {temp([temp.isdir]).name}; %gets only the names of all files
DirNames =DirNames(contains(DirNames,'anm')); %gets only the names of all files


for iDir = 1:1:numel (DirNames)
    iDir;
    dir_data2=[dir_data  DirNames{iDir} '\'];
    temp = dir(dir_data2); %gets  the names of all files and nested directories in this folder
    DirNames2 = {temp([temp.isdir]).name}; %gets only the names of all files
    DirNames2(1:2) =[]; %gets only the names of all files
    DirNames2(contains(DirNames2,'registered'))=[];
    currentSubject_id = str2num(dir_data2(strfind(dir_data2,'anm')+3:strfind(dir_data2,'anm')+8));
    for jDir = 1:1:numel (DirNames2)
        % Get the current session name/date
        date_filename=DirNames2{jDir};

        date_filename_no_suffix=date_filename(1:8);
        date_filename_suffix=date_filename(9:end);
        try
        currentSessionDate = char(datetime(date_filename_no_suffix,'Format','yyyyMMdd','InputFormat','yyyyMMdd'));
        catch
            return
        end
        % Get the  name/date of sessions that are already in the DJ database
        exisitingSubject_id = fetchn(EXP2.Session,'subject_id');
        
        key=[];
        key.subject_id = currentSubject_id;  key.session_date = currentSessionDate;
        
        % Insert a session (and all the dependent tables) only if the animalXsession combination doesn't exist
        if isempty( fetch(EXP2.Session & key)) ||  ~isempty(date_filename_suffix)
            sessions=fetchn(EXP2.Session & key,'session');
            if numel(sessions)>=str2num(date_filename_suffix)
                continue
                end
            if  sum(currentSubject_id == exisitingSubject_id)>0 % test if to restart the session numbering
                temp_key.subject_id = key.subject_id;
                s_n = fetchn(EXP2.Session & temp_key,'session');
                currentSession = s_n(end) + 1;
            else
                currentSession =1;
            end
            
            %% Insert Session
            insert(EXP2.Session, {currentSubject_id, currentSession, currentSessionDate, user_name ,rig} );
            populate(EXP2.SessionID);
            
            k1.subject_id = currentSubject_id;
            k1.session=currentSession;
            k1.local_path_orignal_session = [dir_data2 date_filename];
             %% Insert Session
            insert(EXP2.SessionDirectory, k1 );

        end
    end
end
