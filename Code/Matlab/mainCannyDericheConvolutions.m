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

figure(1)
subplot(3,3,1)
imagesc(image)
title('Image Originale')

%% Choix des parametres (a modifier en fonction de l'image)

% parametres choisis page 179 de l'article pour l'image office.png
alpha = 1; 
omega = 0.0001;

%% Les coefficients du filtre

[c,k,c1,c2,b1,b2,a,a0,a1,a2,a3]=coefficientsDeriche(alpha, omega);

%% f(x), h(x), X(x,y), Y(x,y)

indice=0;
f=zeros(length(-8:0.1:8),1);
for i=-8:0.1:8
    indice=indice+1;
    f(indice)=-c*exp(-alpha*abs(i))*sin(omega*i);
end

indice=0;
h=zeros(length(-8:0.1:8),1);
for j=-8:0.1:8
    indice=indice+1;
    h(indice)=(c1*sin(omega*abs(j))+c2*cos(omega*abs(j)))*exp(-alpha*abs(j));
end

figure(2)
hold on
subplot(2,1,1)
plot(-8:0.1:8, f)
ylim([-0.5, 0.5])
grid on
title(['Reponse impulsionnelle f(x), \alpha=', num2str(alpha), ', \omega=', num2str(omega)])

subplot(2,1,2)
plot(-8:0.1:8, h)
ylim([-0.05, 0.3])
grid on
title(['Reponse impulsionnelle h(x), \alpha=', num2str(alpha), ', \omega=', num2str(omega)])

ligne=0;
f=zeros(length(-8:0.1:8),length(-8:0.1:8));
X=zeros(length(-8:0.1:8),length(-8:0.1:8));
Y=zeros(length(-8:0.1:8),length(-8:0.1:8));
for i=-8:0.1:8
    ligne=ligne+1;
    colonne=0;    
    for j=-8:0.1:8
        colonne=colonne+1;
        f(ligne,colonne)=-((c*k)/(alpha^2+omega^2))*exp(-alpha*(abs(i)+abs(j)))*(sin(omega*i)*(alpha*sin(omega*abs(j))+omega*cos(omega*abs(j)))+sin(omega*j)*(alpha*sin(omega*abs(i))+omega*cos(omega*abs(i))));
        X(ligne,colonne)=((-c*exp(-alpha*abs(i))*sin(omega*i))*(k*(alpha*sin(omega*abs(j))+omega*cos(omega*abs(j)))*exp(-alpha*abs(j))))/(alpha^2+omega^2);
        Y(ligne,colonne)=((k*(alpha*sin(omega*abs(i))+omega*cos(omega*abs(i)))*exp(-alpha*abs(i)))*(-c*exp(-alpha*abs(j))*sin(omega*j)))/(alpha^2+omega^2);
    end
end

figure(3)
hold on
subplot(2,2,1)
h=surf(f);
hold on
gridSurf(h, 30, 30);
title(['Reponse impulsionnelle f(x,y), \alpha=', num2str(alpha), ', \omega=', num2str(omega)])
hold off
hold off

subplot(2,2,2)
h=surf(X);
hold on
gridSurf(h, 30, 30);
title(['Masque X, \alpha=', num2str(alpha), ', \omega=', num2str(omega)])
hold off

subplot(2,2,3)
h=surf(Y);
hold on
gridSurf(h, 30, 30);
title(['Masque Y, \alpha=', num2str(alpha), ', \omega=', num2str(omega)])
hold off

subplot(2,2,4)
h=surf(X+Y);
hold on
gridSurf(h, 30, 30);
title(['X+Y, \alpha=', num2str(alpha), ', \omega=', num2str(omega)])
hold off

%% Reponse impulsionnelle f(n)

indice=0;
f=zeros(1,length(-n*p:n*p));
for i=-n*p:n*p
    indice=indice+1;
    f(indice)=-c*exp(-alpha*abs(i))*sin(omega)*i;
end

%% Reponse impulsionnelle h(n)

indice=0;
h=zeros(length(-n*p:n*p),1);
for j=-n*p:n*p
    indice=indice+1;
    h(indice)=(c1*sin(omega*abs(j))+c2*cos(omega*abs(j)))*exp(-alpha*abs(j));
end

%% Gradient X et Lissage

figure(1)
hold on
tic;
temp=filter2(f, image); % convolution horizontale f et image (donne gradient X)
gradientX=filter2(h, temp); % lissage vertical (gradient X lisse)
temp_filtreDericheConvolutions=toc % 0.0245 s
subplot(3,3,2)
imagesc(gradientX);
title('Gradient X')

%% Gradient Y et Lissage

temp=filter2(f, image'); % convolution verticale f et image (donne gradient Y transpose)
gradientY=filter2(h, temp)'; % lissage horizontal (gradient Y lisse)
subplot(3,3,3)
imagesc(gradientY);
title('Gradient Y')

%% Norme du gradient (magnitude)

normeGradient=sqrt(gradientX.^2+gradientY.^2);

subplot(3,3,4)
imagesc(normeGradient)
title('Norme du gradient')

%% Direction du gradient

directionGradient=atan2d(gradientY,gradientX); % en degre
% atand(s./r) dans l'article

subplot(3,3,5)
imagesc(directionGradient)
title('Direction du gradient')

%% Suppression des non-maxima locaux

res_suppnonmaxima=suppnonmaxima(normeGradient, directionGradient);

subplot(3,3,6)
imagesc(res_suppnonmaxima)
title('Apres suppression des non-maxima locaux')

%% Seuillage par hysteresis

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