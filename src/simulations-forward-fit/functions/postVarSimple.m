function [postVar] = postVarSimple(priorVar,idioVar,sector,time)

J = size(priorVar,2);
j = sector;
t = time;
Omega = zeros(size(priorVar));
switch j
case {1,2}
	Omega(j,j) = 1./idioVar(j);
case 3
	if time<=4
		Omega(j,j) = 1./idioVar(j+t-1);
	else
		Omega(j,j) = 1./idioVar(j+4);
	end
case 4
	if time<=4
		Omega(j,j) = 1./idioVar(2*j+t-1);
	else
		Omega(j,j) = 1./idioVar(2*j+4);
	end
case 5
	if time<=2
		Omega(j,j) = 1./idioVar(2*j+t+2);
	else
		Omega(j,j) = 1./idioVar(2*j+5);
	end
end

postVar = (priorVar\eye(J)+Omega)\eye(J);
