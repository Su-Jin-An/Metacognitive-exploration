function pre_process(subject)

%% Load Data %%
addpath('C:\Users\user\Desktop\Space_Exploration\DATA\raw_data') % add path to your data folder

%% Combine seperate file into one
PI='_Planet_Information.mat';
ME='_MouseEvent.mat';
LIST= {'_Pre', '_Chall1', '_Chall2'};

%% Run by every subject

for sbj= subject
    % [1:6 8:35] % Subject number 1 ~ 35  (Subject #7 is corrupted)
    
    
    %     Load raw data
    nm=num2str(sbj);
    
    Msg=strcat('Loading Subject  ',nm)
    
    P=[];
    M=[];
    
    for list= 1:3 % for task 1 ~ 3
        
        file=strcat(nm,LIST(list),PI); % EX) subject_Pre_Planet_Information.mat
        filename = char(file);
        load (filename);
        
        file=strcat(nm,LIST(list),ME); % EX) subject_Pre_MouseEvent.mat
        filename = char(file);
        load (filename);
        
        clear planet_list;
        planet_list=[];
        mouse_list=[];
        
        if list==1
            planet_list=pre_planet_list;
            mouse_list=pre_mouse_event;
            tag='_TASK_1';
        elseif list==2
            planet_list=chall1_planet_list;
            mouse_list=chall1_mouse_event;
            tag='_TASK_2';
        else
            planet_list=chall2_planet_list;
            mouse_list=chall2_mouse_event;
            tag='_TASK_3';
        end
        
        %% PRE PRSOCESSING - PLANET %%
        
        
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        % % % % PLANET LIST PRE PROCESSING % % % %
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        
        
        Xpoint=[]; % x dot
        Ypoint=[]; % y dot
        Dist=[]; % distance (pixels)
        Rad=[]; % angle (rad)
        planet=[];  % planet #
        Gtime=[];   % global time
        Ltime=[];   % local time
        Ptime=[];   % time passed from previous time
        Udist=[];   % eculidean dist. from previous point
        LorG=[];    % local / global
        typeLorG_previous=[];    % local / global 2*2 type
        typeLorG_current=[];
        
        %         Empty vector for saving data
        planet_result=[];
        
        
        % Sort raw data into pre processed data %
        for i=1:size(planet_list,1)
            planet(size(planet,1)+1,1)=planet_list(i,1);
            Ypoint(size(Ypoint,1)+1,1)=(((planet_list(i,2)/150)*300)+390);
            Xpoint(size(Xpoint,1)+1,1)=(((planet_list(i,3)/pi)*300)+810);
            Dist(size(Dist,1)+1,1)=planet_list(i,2);
            Rad(size(Rad,1)+1,1)=planet_list(i,3);
            Gtime(size(Gtime,1)+1,1)=planet_list(i,4);
            Ltime(size(Ltime,1)+1,1)=planet_list(i,5);
            Ptime(size(Ptime,1)+1,1)=(planet_list(i,5)-planet_list(i,4));
            
            if i==1
                Udist(size(Udist,1)+1,1)=0;
            else
                Udist(size(Udist,1)+1,1)=sqrt((((((planet_list(i,3)/pi)*300)+810)-(((planet_list(i-1,3)/pi)*300)+810)).^ 2)+(((((planet_list(i,2)/150)*300)+390)-(((planet_list(i-1,2)/150)*300)+390)) .^ 2));
            end
        end
        
        % define local / global
        m_dist=median(Udist);
        
        for i=1:size(planet_list,1)
            if Udist(i) <= m_dist
                LorG(size(LorG,1)+1,1)=0;
            else
                LorG(size(LorG,1)+1,1)=1;
            end
        end
        
        %% Local / Global 2*2 [Uncertainty based on current state]
        typeLorG_current(1,1) = 0;
        for j=2:size(LorG,1)
            t = LorG(j,1);
            t1 = LorG(j-1,1);
            
            if t==0 && t1==0
                typeLorG_current(size(typeLorG_current,1)+1,1) = 1;
            elseif t==1 && t1==0
                typeLorG_current(size(typeLorG_current,1)+1,1) = 2;
            elseif t==0 && t1==1
                typeLorG_current(size(typeLorG_current,1)+1,1) = 3;
            elseif t==1 && t1==1
                typeLorG_current(size(typeLorG_current,1)+1,1) = 4;
            end
        end
        
        %% Local / Global 2*2 [Uncertainty based on previous state]
        for j=2:size(LorG,1)
            t = LorG(j,1);
            t1 = LorG(j-1,1);
            
            if t==0 && t1==0
                typeLorG_previous (size(typeLorG_previous,1)+1,1) = 1;
            elseif t==1 && t1==0
                typeLorG_previous (size(typeLorG_previous,1)+1,1) = 2;
            elseif t==0 && t1==1
                typeLorG_previous (size(typeLorG_previous,1)+1,1) = 3;
            elseif t==1 && t1==1
                typeLorG_previous (size(typeLorG_previous,1)+1,1) = 4;
            end
        end
        typeLorG_previous(j,1)=5;
        
        
        planet_result=[planet_result; planet Ypoint Xpoint Dist Rad Gtime Ltime Ptime Udist repmat(m_dist,size(planet_list,1),1) LorG typeLorG_previous typeLorG_current];
        planet_tag={'Planet #','Y point','X point','Distance (pixels)','Angle (rad)','Global starting time','Local starting time','Duration time','Euclidean Distance','Median Distance','Local = 0 / Global = 1' };
        
        id=ones(size(planet_result, 1), 1)*list;
        P=[P; id planet_result]; % Combined Task 1,2,3 into 1 dataframe
        
        
        %% PRE PROCESSING - SPACE %% [mouse]
        
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        % % % % MOUSE EVENT PRE PROCESSING % % %
        % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        
        
        planet=[];  % planet #
        Gtime=[];   % global time
        Ltime=[];   % local time
        Ptime=[];   % time passed from previous time
        x=[];   % x coordinate
        y=[];   % y coordinate
        Udist=[];   % eculidean dist. from previous point
        touch=[];   % touch #
        gain=[];    % gain
        %         Empty vector for saving data
        mouse_result=[];
        
        %         unique point vector
        uniq=[];
        
        
        
        %   PRE PROCESSING
        for i=1:size(mouse_list,1)
            planet(size(planet,1)+1,1)=mouse_list(i,1);
            Gtime(size(Gtime,1)+1,1)=mouse_list(i,2);
            Ltime(size(Ltime,1)+1,1)=mouse_list(i,3);
            
            if i==1
                num=0;
                num=i+1;
                Ptime(size(Ptime,1)+1,1)=(mouse_list(2,2)-mouse_list(1,2));
                Udist(size(Udist,1)+1,1)=0;
                
            elseif i==size(mouse_list,1)
                Ptime(size(Ptime,1)+1,1)=mouse_list(i,3)-mouse_list(i-1,3)
                Udist(size(Udist,1)+1,1)=sqrt(((mouse_list(i,4)-mouse_list((i-1),4)).^ 2)+((mouse_list(i,5)-mouse_list((i-1),5)) .^ 2));
                
            else
                num=0;
                num=i+1;
                Ptime(size(Ptime,1)+1,1)=(mouse_list(num,2)-mouse_list(i,2));
                Udist(size(Udist,1)+1,1)=sqrt(((mouse_list(i,4)-mouse_list((i-1),4)).^ 2)+((mouse_list(i,5)-mouse_list((i-1),5)) .^ 2));
            end
            
            x(size(x,1)+1,1)=mouse_list(i,4);
            y(size(y,1)+1,1)=mouse_list(i,5);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if sbj <= 25
                gain(size(gain,1)+1,1)=mouse_list(i,6); % COL 7 for Subject 26-35 / COL 6 for Subject 1:6:8:25
            else
                gain(size(gain,1)+1,1)=mouse_list(i,7); % COL 7 for Subject 26-35 / COL 6 for Subject 1:6:8:25
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %    COUNTING NEW TOUCH
            if Udist(size(Udist,1),1) < 3
                touch(size(touch,1)+1,1)=0; % same touch
            else
                touch(size(touch,1)+1,1)=1; % new touch
            end
        end
        
        mouse_result=[mouse_result; planet Gtime Ltime Ptime x y Udist touch gain];
        
        
        %   CALCULATING CONFIDENCE (DURATION OF TIME)
        %   INDEXING SAME TOUCHING POINT (UDIST < 3)
        tempN=0;
        for m=1:size(mouse_result,1)
            
            if mouse_result(m,8)==1
                tempN=tempN+1;
                mouse_result(m,10)=tempN;
            else
                mouse_result(m,10)=tempN;
            end
        end
        
        
        n = unique(mouse_result(:,10));
        for l=1:size(n,1)
            index = find(mouse_result(:,10) == n(l));
            mouse_result(index(length(index)),11)=sum(mouse_result(index,4));   % Total time spending on the point (Confidence)
            mouse_result(index(length(index)),12)=length(index);                % Number of sampling
            mouse_result(index(length(index)),13)=sum(mouse_result(index,9));   % Total gain
        end
        
        
        %   CALCULATING REPETITING POINT
        [x z q]=unique(mouse_result(:,[1,5,6]),'rows');
        qn = hist(q,numel(unique(q)));
        qn=qn.';
        uniq=[x qn];
        
        id=ones(size(mouse_result, 1), 1)*list;
        M=[M; id mouse_result]; % Combined Task 1,2,3 into 1 dataframe
        
        mouse_tag={'Planet #','Global starting time','Local starting time','Duration time','X point','Y point','Euclidean Distance','New Touch - 1','Gain','Group #','Confidecne (Time)','Number of Sampling','Total Gain' };
        
        
        
        %% Saving %% - per task
        
        % % %         save_file=strcat('C:\Users\user\Desktop\KWIK_RESULT\SPACE_EXPLORATION\Ver_3\Data\Subject_',nm,tag,'.mat');
        % % %
        % % %         filename = char(save_file);
        % % %         save(filename,'planet_result', 'mouse_result', 'mouse_tag', 'planet_tag' ,'Analysis_V1');
        % % %
        
        
    end
    
    %% Saving %% - combined version (P, M)
    save_file=strcat('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\Subject_',nm,'.mat');
    
    filename = char(save_file);
    save(filename,'P', 'M' , 'mouse_tag' , 'planet_tag');
    Msg=strcat('Saved Subject  ',nm)
end
end
