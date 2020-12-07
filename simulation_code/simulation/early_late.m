function early_late(subject)
%% LOAD PRE PROCESS DATA %%

addpath('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\') % add path to your data folder
early_late_Index=[];
result=[]; % for excel

for sbj= subject
    %     subject
    %     [1:6 8:35] % Subject number - 35
    nm=num2str(sbj);
    Msg=strcat('Loading Subject  ',nm)
    
    file=strcat('Subject_',nm,'.mat');
    filename = char(file);
    load (filename);
    
    
    %% COMBINE HIST for TASK 1,2,3 %%
    
    index = find(P(:,1)==1|P(:,1)==2);
    temp_num=size(index,1);
    
    k=1;
    while k==1
        if(mod(temp_num,2)==0)
            k=2;
        else
            k=1;
            temp_num=temp_num-1;
        end
    end
    
    temp_num=temp_num/2
    
    a1=1:temp_num;
    a2=temp_num+1:size(index,1);
    
    clear early_late_Index
    early_late_Index = [repmat(1,size(a1,2),1); repmat(2,size(a2,2),1);];
    
    
    %% Saving %% - combined version (P, M)
    save_file=strcat('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\Subject_',nm,'.mat');
    
    filename = char(save_file);
    save(filename,'P', 'M' , 'mouse_tag' , 'planet_tag', 'kwik_absValue', 'geodesic','early_middle_late_Index', 'early_late_Index');
    Msg=strcat('Saved Subject  ',nm)
    
    result=[result; repmat(sbj,size(index,1),1)  P(index,10) P(index,12) P(index,13) geodesic(index,:) kwik_absValue(index,:)  early_middle_late_Index(index,:) early_late_Index(index,:)];
end
% Save in Excel
save_file=strcat('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\early_late_Index.xls');
xlswrite(save_file, result);
end