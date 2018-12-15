function resFinal = SeuillageParHysteresis(res, Smin, Smax)
    N=3;
    P=3;
    [n,p]=size(res);
    
    resAvecZeros=[zeros(1,p+(P-1)); [zeros(n,1) res zeros(n,1)]; zeros(1,p+(P-1))];
    resFinal=-ones(size(resAvecZeros));
    
    for i = 2:size(resAvecZeros,1)-1
        for j = 2:size(resAvecZeros,2)-1
            
            if (resAvecZeros(i,j)<=Smin)
                resFinal(i,j)=0;
            else
                if ((resAvecZeros(i,j)>Smin) && (resAvecZeros(i,j)<Smax))
                    fenetre=resAvecZeros((i-1):(i+1),(j-1):(j+1));
                    if ~(sum(sum(ismember(fenetre>=Smax,1)))>=0)
                        resFinal(i,j)=0;
                    else
                            resFinal(i,j)=1;
                    end
                else
                    %if (resAvecZeros(i,j)>=Smax)
                    resFinal(i,j)=1;
                    %end
                end
            end
        end
    end 
    
    resFinal(:,1)=[];
    resFinal(1,:)=[];
    resFinal(:,end)=[];
    resFinal(end,:)=[];
end