function calculate_Geodesic(subject)
%% LOAD PRE PROCESS DATA %%
%% WORKING VERSION - 20180412 %%

addpath('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\') % add path to your data folder

%% Parameter for display.
ms = 50;
lw = 1.5;
v1 = -15; v2 = 20;

for sbj= subject
    %     [1:6 8:35] % Subject number - 25
    
    nm=num2str(sbj);
    Msg=strcat('Loading Subject  ',nm)
    
    file=strcat('Subject_',nm,'.mat');
    filename = char(file);
    load (filename);
    
    
    %% Initialize Variable
    x=[];
    geodesic=[0]; % Initial Uncertainty
    
    % KNN
    K=10; %
    indx=find(P(:,1)==1);
    
    %% Calculate XY uncertainty value for each planet
    for i=1:size(P, 1)
        X=[P(i, 4)-809; P(i,3)-389]; % current input
        
        if isempty(x) % First Trial
            x=[x; X'];
            
            
        elseif size(x,1) <=K
            
            k = size(x,1);
            
            x=[x; X']; % Experience sample
            
            % Compute the pairwise Euclidean distance matrix.
            Dist = pdist(x);
            D0 = squareform(Dist);
            % Compute the k-NN connectivity.
            [DNN,NN] = sort(D0);
            NN = NN(2:k+1,:);
            DNN = DNN(2:k+1,:);
            % Adjacency matrix, and weighted adjacency.
            B = repmat(1:size(x,1), [k 1]);
            A = sparse(B(:), NN(:), ones(k*size(x,1),1));
            % Weighted adjacency (the metric on the graph).
            W = sparse(B(:), NN(:), DNN(:));
            
            % Display the graph.
            options.lw = lw;
            options.ps = 0.01;
            clf;
            hold on;
            % figure(2);
            scatter3(x(:,1),x(:,2),repmat(1,size(x,1),1), ms, 'filled');
            plot_graph(A, x, options);
            colormap jet(256);
            view(v1,v2); axis('equal'); axis('off');
            zoom(.8);
            
            % Geodesic with Floyd Algorithm
            % Make the graph symmetric.
            D = full(W);
            D = (D+D')/2;
            
            % Initialize the matrix
            D(D==0) = Inf;
            
            % Add connexion between a point and itself.
            D = D - diag(diag(D));
            
            % Floyd Algorithm
            % Implement the Floyd algorithm to compute the full distance matrix D, where D(i,j) is the geodesic distance between
            for j=1:size(x,1)
                % progressbar(i,n);
                D = min(D,repmat(D(:,j),[1 size(x,1)])+repmat(D(j,:),[size(x,1) 1]));
            end
            
            geodesic=[geodesic; D(i,i-1)];
            
        else
            
            k = K;
            
            x=[x; X']; % Experience sample
            
            % Compute the pairwise Euclidean distance matrix.
            Dist = pdist(x);
            D0 = squareform(Dist);
            % Compute the k-NN connectivity.
            [DNN,NN] = sort(D0);
            NN = NN(2:k+1,:);
            DNN = DNN(2:k+1,:);
            % Adjacency matrix, and weighted adjacency.
            B = repmat(1:size(x,1), [k 1]);
            A = sparse(B(:), NN(:), ones(k*size(x,1),1));
            % Weighted adjacency (the metric on the graph).
            W = sparse(B(:), NN(:), DNN(:),size(x,1),size(x,1)); % S = sparse(i,j,v,m,n)은 S의 크기를 mxn으로 지정합니다.
            
            % Display the graph.
            options.lw = lw;
            options.ps = 0.01;
            clf;
            hold on;
            % figure(2);
            scatter3(x(:,1),x(:,2),repmat(1,size(x,1),1), ms, 'filled');
            plot_graph(A, x, options);
            colormap jet(256);
            view(v1,v2); axis('equal'); axis('off');
            zoom(.8);
            
            % Geodesic with Floyd Algorithm
            % Make the graph symmetric.
            D = full(W);
            D = (D+D')/2;
            
            % Initialize the matrix
            D(D==0) = Inf;
            
            % Add connexion between a point and itself.
            D = D - diag(diag(D));
            
            % Floyd Algorithm
            % Implement the Floyd algorithm to compute the full distance matrix D, where D(i,j) is the geodesic distance between
            for j=1:size(x,1)
                % progressbar(i,n);
                D = min(D,repmat(D(:,j),[1 size(x,1)])+repmat(D(j,:),[size(x,1) 1]));
            end
            
            geodesic=[geodesic; D(i,i-1)];
            
        end
    end
    
    %% Saving %% - combined version (P, M)
    save_file=strcat('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\Subject_',nm,'.mat');
    
    filename = char(save_file);
    save(filename,'P', 'M' , 'mouse_tag' , 'planet_tag' , 'kwik_absValue' , 'geodesic');
    Msg=strcat('Saved Subject  ',nm)
    
    
end
end