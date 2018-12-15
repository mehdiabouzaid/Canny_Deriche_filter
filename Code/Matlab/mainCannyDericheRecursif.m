%%
clc
close all
clear

path=which('mainCannyDericheConvolutions.m');
path=[path(1:(end-length('Code/Matlab/mainCannyDericheConvolutions.m')))];
addpath([path 'Donnees'])

%% Image originale

nomImage='office.png';
image=imread(nomImage);
[n,p,z] = size(image);
disp(['Dimensions image : n=', num2str(n), ' p=', num2str(p), ' z=', num2str(z)])

if z>1
    image=rgb2gray(image);
end

image=double(image);

figure
subplot(3,3,1)
imagesc(image)
title('Image Originale')

%% Choix des parametres (a modifier en fonction de l'image)

% parametres choisis page 179 de l'article pour l'image office.png
alpha = 1; 
omega = 0.0001;

%% Les coefficients du filtre

[c,k,c1,c2,b1,b2,a,a0,a1,a2,a3]=coefficientsDeriche(alpha, omega);

%% Gradient X et Lissage

tic;
gradientX = filtreDericheRecursif(image, b1, b2, a, a0, a1, a2, a3);
temps_filtreDericheRecursif=toc % 0.0082 s

subplot(3,3,2)
imagesc(gradientX)
title('Gradient X')

%% Gradient Y et Lissage

gradientYtranspose = filtreDericheRecursif(image', b1, b2, a, a0, a1, a2, a3);
gradientY=gradientYtranspose';

subplot(3,3,3)
imagesc(gradientY)
title('Gradient Y')

%% Norme du gradient (magnitude)

normeGradient = sqrt(gradientX.^2 + gradientY.^2);

subplot(3,3,4)
imagesc(normeGradient)
title('Norme du gradient')

%% Direction du gradient

directionGradient = atan2d(gradientY,gradientX); % en degre

subplot(3,3,5)
imagesc(directionGradient)
title('Direction du gradient')

%% Suppression des non-maxima locaux

res_suppnonmaxima=suppnonmaxima(normeGradient, directionGradient);

subplot(3,3,6)
imagesc(res_suppnonmaxima)
title('Apres suppression des non-maxima locaux')

%% Hysteresis thresholding (using two thresholds)

% Seuil minimum
Smin = 20;

% Seuil maximum
Smax = 40;

res = seuillageParHysteresis(res_suppnonmaxima, Smin, Smax);

subplot(3,3,8)
imshow(res)
title('Apres seuillage par hysteresis')
hold off

%% Resultat

figure
imshow(res)

%% Fonctions

function R = filtreDericheRecursif(image, b1, b2, a, a0, a1, a2, a3)
    [n,p]=size(image);
    
    %% Gradient
    %% Y+
    Yp=zeros(n,p);

    debut_j=1;
    %Yp(:,debut_j)=zeros(n,1);
    debut_j=debut_j+1;
    Yp(:,debut_j)=image(:,debut_j-1)-b1*Yp(:,debut_j-1);
    debut_j=debut_j+1;
    for j=debut_j:p
        Yp(:,j)=image(:,j-1)-b1*Yp(:,j-1)-b2*Yp(:,j-2);
    end

    %% Y-
    Ym=zeros(n,p);

    fin_j=p;
    %Ym(:,fin_j)=zeros(n,1);
    fin_j=fin_j-1;
    Ym(:,fin_j)=image(:,fin_j+1)-b1*Ym(:,fin_j+1);
    fin_j=fin_j-1;
    for j=fin_j:-1:1
        Ym(:,j)=image(:,j+1)-b1*Ym(:,j+1)-b2*Ym(:,j+2);
    end

    %% S
    S=a*(Yp-Ym);
    
    %% Lissage
    %% R+
    Rp=zeros(n,p);

    debut_i=1;
    Rp(debut_i,:)=a0*S(debut_i,:);
    debut_i=debut_i+1;
    Rp(debut_i,:)=a0*S(debut_i,:)+a1*S(debut_i-1,:)-b1*Rp(debut_i-1,:);
    debut_i=debut_i+1;
    for i=debut_i:n
        Rp(i,:)=a0*S(i,:)+a1*S(i-1,:)-b1*Rp(i-1,:)-b2*Rp(i-2,:);
    end

    %% R-
    Rm=zeros(n,p);

    fin_i=n;
    %Rm(fin_i,:)=zeros(1,p);
    fin_i=fin_i-1;
    Rm(debut_i,:)=a2*S(fin_i+1,:)-b1*Rm(fin_i+1,:);
    fin_i=fin_i-1;
    for i=fin_i:-1:1
        Rm(i,:)=a2*S(i+1,:)+a3*S(i+2,:)-b1*Rm(i+1,:)-b2*Rm(i+2,:);
    end

    %% R
    R=Rm+Rp;
end