function [ grid ] = default_dist(planet_size,x,y,std)
    dim = size(x,2);
     
    %make mesh grid
    xgv = 1:planet_size(1);
    ygv = 1:planet_size(2);
    [X,Y] = meshgrid(xgv,ygv);
    
    %calculate grid
    grid = zeros(planet_size(1),planet_size(2),dim);
    for ii = 1:dim
       xx = x(ii);
       yy = y(ii);
       grid(:,:,ii) = exp(-((X-xx).^2 + (Y-yy).^2)./ (2 .* (std.^2)));
       cur_grid = grid(:,:,ii);
       C = max(cur_grid(:)); %normalize constant
       grid(:,:,ii) = grid(:,:,ii) ./ C;
    end
    
end

