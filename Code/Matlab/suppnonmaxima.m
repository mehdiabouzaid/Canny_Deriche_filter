function normeGradient = suppnonmaxima(normeGradient, arg)
    [n,p]=size(normeGradient);
    masque = boolean(zeros(n,p));

    arg(arg<0)=arg(arg<0)+180;
    arg((arg>=0 & arg<22.5) | (arg>=157.5 & arg<=180))=1;
    arg(arg>=22.5 & arg<67.5)=2;
    arg(arg>=67.5 & arg<112.5)=3;
    arg(arg>=112.5 & arg<157.5)=4;
 
    for i = 2:(n-1)
        for j = 2:(p-1)
            switch arg(i,j)
                case 1 % [0; 22.5[ ou [157.5; 180] degres
                    masque(i,j) = (normeGradient(i,j)>=max(normeGradient(i,j+1),normeGradient(i,j-1)));
                case 2 % [22.5; 67.5[ degres
                    masque(i,j) = (normeGradient(i,j)>=max(normeGradient(i-1,j+1),normeGradient(i+1,j-1)));
                case 3 % [67.5; 112.5[ degres
                    masque(i,j) = (normeGradient(i,j)>=max(normeGradient(i-1,j),normeGradient(i+1,j)));
                case 4 % [112.5; 157.5[ degres
                    masque(i,j) = (normeGradient(i,j)>=max(normeGradient(i-1,j-1),normeGradient(i+1,j+1)));                
            end
        end
    end 
    
    normeGradient(~masque) = 0;
end