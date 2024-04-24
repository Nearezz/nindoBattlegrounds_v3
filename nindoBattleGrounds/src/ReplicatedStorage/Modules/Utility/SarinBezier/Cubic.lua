return function(T, P1, P2, P3, P4)
	return (1 - T)^3*P1 + 3*(1 - T)^2*T*P2 + 3*(1 - T)*T^2*P3 + T^3*P4
end