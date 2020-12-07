function early_late_Histogram(subject)
%% LOAD PRE PROCESS DATA %%

addpath('C:\Users\user\Desktop\Space_Exploration\DATA\processed_data\') % add path to your data folder
load('Colormaps_hist.mat','histCmap')
cc=jet(44);
cc=flipud(cc);

XY1=[];
XY2=[];

for sbj= subject
    
    nm=num2str(sbj);
    Msg=strcat('Loading Subject  ',nm)
    
    file=strcat('Subject_',nm,'.mat');
    filename = char(file);
    load (filename);
    
    
    %% COMBINE HIST for TASK 1,2,3 %%
    for j=1:2
        index = find(early_late_Index==j);
        tmp=[repmat(sbj,size(index,1),1) P(index, 4)-810 P(index, 3)-390]
        
        if j==1
            XY1=[XY1; tmp];
        else
            XY2=[XY2; tmp];
        end
    end
end % subject

% % % figure
% % % for k=[1:6 8:44]
% % %     ind=find(XY1(:,1)==k);
% % %     scatterhist(XY1(ind,2),XY1(ind,3),'Color',cc(k,:));
% % %     hold on
% % % end
% % % hold off


for list=1:2
    %         define equal-sized bins that divide the [-1,1] grid into 10x10 quadrants
    mn = [0 0]; mx = [300 300];  % mn = min(XY); mx = max(XY);
    N = 30;
    edges = linspace(mn(1), mx(1), N+1);
    
    A=(1:1:88);
    if list==1
        XY_total=XY1;
    elseif list==2
        XY_total=XY2;
    end
    
    
    f=figure;
    % 2D histogram of bins count
    [~,subs] = histc(XY_total(:,2:3), edges, 1);
    subs(subs==N+1) = N;
    H_total = accumarray(subs, 1, [N N]);
    
    
    % plot histogram
    imagesc(H_total.');
    axis image xy;
    set(gca, 'TickDir','out')
    set(gca,'xtick',[]);
    set(gca,'xticklabel',[]);
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    c=colormap('gray');
    colorbar;
    axis square
    set(f,'color','white');
    caxis([0 40])
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    hold off
    
    
    % % %     hist3(XY_total(:,2:3))
    % % %     caxis([0 68])
    % % %     view(3)
    % % %     set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    % % %     axis image xy;
    % % %     set(gca, 'TickDir','out')
    % % %     set(gca,'xtick',[]);
    % % %     set(gca,'xticklabel',[]);
    % % %     set(gca,'ytick',[]);
    % % %     set(gca,'yticklabel',[]);
    
    
    
    
    %% Scatter plot with Density function
    figure
    %     scatterhist(XY_total(:,2),XY_total(:,3),'Group',XY_total(:,1),'Kernel','on','Location','SouthEast','Direction','out','Color','kbr','LineStyle',{'-','-.',':'},'LineWidth',[2,2,2],'Marker','+od','MarkerSize',[4,5,6]);
    scatterhist(XY_total(:,2),XY_total(:,3),'Group',XY_total(:,1),'Kernel','on','Location','NorthEast','Direction','out','Color',cc,'Marker','.','MarkerSize',20, 'Legend', 'off', 'LineStyle',{'-'}, 'LineWidth',[2], 'NBins',[10,10])
    colormap(cc)
    axis square
    xlim([0 300]);
    ylim([0 300]);
    set(gca,'color','black');
    set(gca,'xlabel',[]);
    set(gca,'ylabel',[]);
    set(gcf, 'color','white')
    set(gca,'xtick',[]);
    set(gca,'xticklabel',[]);
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    fig = gcf;
    fig.InvertHardcopy = 'off';
    
    figure
    for k=1:size(XY_total,1)
        x_pt=XY_total(k,2);
        y_pt=XY_total(k,3);
        z_pt=ones(size(x_pt,1),1);
        
        % change size of markers with confidence
        %             subplot(1,3,list)
        plot(x_pt,y_pt,'MarkerFaceColor',cc(XY_total(k,1),:),'MarkerEdgeColor',cc(XY_total(k,1),:),'LineStyle','none','Marker','.','MarkerSize', 20);
        colormap(cc)
        hold on
        %             colorbar
        %             c=colorbar('Position', [0.1 0.5 0.01 0.3]);
        %             c.TickLabels = {[]};
        axis square
        
        xlim([0 300]);
        ylim([0 300]);
        set(gca,'color','black');
        set(gca,'xlabel',[]);
        set(gca,'ylabel',[]);
        set(gcf, 'color','white')
        set(gca,'xtick',[]);
        set(gca,'xticklabel',[]);
        set(gca,'ytick',[]);
        set(gca,'yticklabel',[]);
        hold on
    end
    hold off
    
end

end


