function findMedian_Udist_Geodesic(subject)

%% LOAD PRE PROCESS DATA %%
%% WORKING VERSION - 20180412 %%

addpath('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\') % add path to your data folder

sbj_median=[];
total=[];

for sbj=subject
    %     [1:6 8:35] % Subject number - 25
    
    nm=num2str(sbj);
    Msg=strcat('Loading Subject  ',nm)
    
    file=strcat('Subject_',nm,'.mat');
    filename = char(file);
    load (filename);
    
    temp_geo=[];
    for j=1:3
        indx=find(P(:,1)==j);
        sbj_median(sbj,j)= P(indx(1),11);
        sbj_median(sbj,j+3)=median(geodesic(indx,1));
        
        temp_geo=[temp_geo; repmat(median(geodesic(indx,1)),size(indx,1),1)];
    end
    
    geodesic=[geodesic temp_geo];
    
    LorG=[];
    typeLorG_previous=[];
    
    %% Type of Exploration
    for i=1:size(P,1)
        if geodesic(i,1) <= geodesic(i,2)
            LorG(size(LorG,1)+1,1)=0; % Local sampling
        else
            LorG(size(LorG,1)+1,1)=1; % Global sampling
        end
    end
    
    %% Local / Global 2*2 [Uncertainty based on previous state]
    for j=2:size(LorG,1)
        t = LorG(j,1);
        t1 = LorG(j-1,1);
        
        if t==0 && t1==0 % t1 - previous state & t-current state (uncertainty of previous state)
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
    
    geodesic=[geodesic LorG typeLorG_previous];
    
    %% Saving %% - combined version (P, M)
    save_file=strcat('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\Subject_',nm,'.mat');
    
    filename = char(save_file);
    save(filename,'P', 'M' , 'mouse_tag' , 'planet_tag', 'kwik_absValue', 'geodesic');
    Msg=strcat('Saved Subject  ',nm)
    
    
    %     total=[total; [repmat(sbj,size(P,1),1) P(:,1:2) geodesic kwik_absValue]];
    
end
% total_task1=total(find(total(:,2)==1),:);
end