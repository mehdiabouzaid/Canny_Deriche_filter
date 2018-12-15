function []=gridSurf(h, nbLignesx, nbLignesy)

    set(h,'LineStyle','none')
    x=get(h,'XData');
    y=get(h,'YData');
    z=get(h,'ZData');
    xlabel('x')
    ylabel('y')
    zlabel('z')

    % Tracage des lignes
    xnblignes = nbLignesx;
    ynblignes = nbLignesy;
    xpas = round(length(x)/xnblignes);
    ypas = round(length(y)/ynblignes);

    for i = 1:ypas:length(y)
        Y1 = y(i)*ones(size(x));
        Z1 = z(i,:);
        plot3(x,Y1,Z1,'-k');
    end

    for i = 1:xpas:length(x)
        X2 = x(i)*ones(size(y));
        Z2 = z(:,i);
        plot3(X2,y,Z2,'-k');
    end
end