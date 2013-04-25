function y=gabor2asym(alfa,mi,dec,x)

tmp_x_mi=x-mi;
y=exp((-alfa*( tmp_x_mi ).^2 )./ (1+ dec*( tmp_x_mi ) .* (atan(1e16*(tmp_x_mi))+pi/2)/pi));
y=y/norm(y);
return