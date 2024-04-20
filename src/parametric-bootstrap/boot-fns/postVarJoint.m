function [postVar] = postVarJoint(priorVar,idioVar,sector1,sector2,time)

if ~isempty(sector2) && (sector1==sector2 || (sector1==1 && sector2==2))
	sector2 = [];
end
if ~isempty(sector2) && sector1==2 && sector2==1
	sector1 = 1;
	sector2 = [];
end

J = size(priorVar,2);
j = sector1;
k = sector2;
t = time;
Omega = zeros(size(priorVar));
if isempty(k);
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
else
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
	switch k
	case {1,2}
		Omega(k,k) = 1./idioVar(k);
	case 3
		if time<=4
			Omega(k,k) = 1./idioVar(k+t-1);
		else
			Omega(k,k) = 1./idioVar(k+4);
		end
	case 4
		if time<=4
			Omega(k,k) = 1./idioVar(2*k+t-1);
		else
			Omega(k,k) = 1./idioVar(2*k+4);
		end
	case 5
		if time<=2
			Omega(k,k) = 1./idioVar(2*k+t+2);
		else
			Omega(k,k) = 1./idioVar(2*k+5);
		end
	end
end
postVar = (priorVar\eye(J)+Omega)\eye(J);
