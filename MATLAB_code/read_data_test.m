fid=fopen('Out_Q_1130_1G.tim','r'); 
best_data=[]; 
while 1     
	tline=fgetl(fid);     
	if ~ischar(tline),break;
	end     
	tline=str2num(tline);     
	best_data=[best_data;tline];
end