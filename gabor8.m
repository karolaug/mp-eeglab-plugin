function y=gauss8(alfa,mi,x)

y=exp((-alfa*( x-mi).^8 ));
y=y/norm(y);
return