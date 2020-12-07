x_list = [50 150 250];
y_list = [50 150 250];

for i =1:3
    for j =1:3
        f = figure
        plot(x_list(i),y_list(j),'*', 'MarkerSize', 12, 'Color','k');
        ylim([0 300]);
        xlim([0 300]);
        set(gca,'Color','w') %
        set(gca,'XTick',[], 'YTick', [])
        set(gca,'YDir', 'reverse');
        set(gca,'XColor','w', 'YColor','w');
        set(gcf,'Color','none')
        set(gcf,'units','points','position',[100,100,300,260])
        set(gcf, 'InvertHardCopy', 'off');
        
        deg = (x_list(i) ./ 300) .* pi; % rad
        dstnt = (3 .* 50) .* (y_list(j) ./ 300);
        
        fileName = sprintf('%d_%d.jpg', deg, dstnt);
        saveas(gcf, fileName);
        %         fig = gcf;
        %         fig.Color = 'black';
        
        
    end
end