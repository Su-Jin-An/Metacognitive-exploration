function KWIK_absVal(subject)

%% LOAD PRE PROCESS DATA %%
%% WORKING VERSION - 20180106 %%

addpath('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\') % add path to your data folder

for sbj= subject
    %     [1:6 8:35] % Subject number - 25
    
    nm=num2str(sbj);
    Msg=strcat('Loading Subject  ',nm)
    
    file=strcat('Subject_',nm,'.mat');
    filename = char(file);
    load (filename);
    
    %% Initialize Variable
    X=[];
    kwik_absValue=[0 0 0]; % Initial Uncertainty
    
    % KNN
    K=3;
    
    %% Calculate XY uncertainty value for each planet
    for i=1:size(P, 1)
        
        x=[P(i, 4)-809; P(i,3)-389]; % current input
        temp_X=[];
        
        if isempty(X) % First Trial
            X=[X; x'];
            
        elseif size(X,1) <=K
            
            [IDX,distance] = knnsearch(X, x','k',size(X,1));
            
            for j=1:size(IDX,2)
                temp_X=[temp_X; abs(X(IDX(1,j),1)-x(1,1)) abs(X(IDX(1,j),2)-x(2,1))];
            end
            
            [U S V]=svd(temp_X'*temp_X);
            temp=1;  % check for singluar value being 1
            for m=1:size(S,2)
                if round(S(m,m))==0
                    if temp==1
                        index_m=m-1;
                        temp=0;
                    else
                        temp=0;
                    end
                    m=size(S,2)+1;
                else
                    index_m=size(S,2);
                end
            end
            
            q=temp_X*U(:,1:index_m)*(inv(S(1:index_m,1:index_m)))*U(:,1:index_m)'*[1;1]; % calculate q
            
            
            % % %  Check if the eigenvalue is zero
            % % %             e = eig(X'*X);
            % % %             if  e(e<=0)
            % % %                 zero
            % % %
            % % %             end
            
            % % %  Checking whether it satisfies x=X'*q
            % % %                     D'*q
            % % %             x
            % % %
            
            
            
            n1 = norm(q);
            n2 = 1-n1;
            n3 = norm(temp_X'\[1;1]);
            
            kwik_absValue=[kwik_absValue; n1 n2 n3];
            
            
            X=[X; x']; % Experience sample
            
        else
            
            [IDX,distance] = knnsearch(X, x','k',K);
            
            for j=1:size(IDX,2)
                temp_X=[temp_X; abs(X(IDX(1,j),1)-x(1,1)) abs(X(IDX(1,j),2)-x(2,1))];
            end
            
            
            [U S V]=svd(temp_X'*temp_X);
            temp=1;  % check for singluar value being 1
            for m=1:size(S,2)
                if round(S(m,m))==0
                    if temp==1
                        index_m=m-1;
                        temp=0;
                    else
                        temp=0;
                    end
                    m=size(S,2)+1;
                else
                    index_m=size(S,2);
                end
            end
            
            q=temp_X*U(:,1:index_m)*(inv(S(1:index_m,1:index_m)))*U(:,1:index_m)'*[1;1]; % calculate q
            
            n1 = norm(q);
            n2 = 1-n1;
            n3 = norm(temp_X'\[1;1]);
            
            kwik_absValue=[kwik_absValue; n1 n2 n3];
            
            
            X=[X; x']; % Experience sample
        end
    end
    
    %     kwik=[kwik kwik_knn];
        %% Saving %% - combined version (P, M)
        save_file=strcat('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\Subject_',nm,'.mat');
    
        filename = char(save_file);
        save(filename,'P', 'M' , 'mouse_tag' , 'planet_tag', 'kwik_absValue');
        Msg=strcat('Saved Subject  ',nm)
    
    %     clear
    
end % Calculate XY uncertainty

end
