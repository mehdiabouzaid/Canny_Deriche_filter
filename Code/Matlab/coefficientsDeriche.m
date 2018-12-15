function [c,k,c1,c2,b1,b2,a,a0,a1,a2,a3]=coefficientsDeriche(alpha, omega)

    c=(1-2*exp(-alpha)*cos(omega)+exp(-2*alpha))/(exp(-alpha)*sin(omega));
    k=((1-2*exp(-alpha)*cos(omega)+exp(-2*alpha))*(alpha^2+omega^2))/(2*alpha*exp(-alpha)*sin(omega)+omega-omega*exp(-2*alpha));

    c1=(k*alpha)/(alpha^2+omega^2);
    c2=(k*omega)/(alpha^2+omega^2);

    b1=-2*exp(-alpha)*cos(omega);
    b2=exp(-2*alpha);

    a=-c*exp(-alpha)*sin(omega);
    a0=c2;
    a1=(-c2*cos(omega)+c1*sin(omega))*exp(-alpha);
    a2=a1-c2*b1;
    a3=-c2*b2;
end