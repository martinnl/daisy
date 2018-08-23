a = imread('prism.tif');
bwa = sum(a,3)>0;
delta = 0.2
[rows,cols] = find(bwa==1);
fid = fopen('prism.il','w');

for rr = 1:length(rows)
    xx = rows(rr);
    yy = cols(rr);
        if bwa(xx,yy)
            cmdStr = [' (daisyLeRect (hiGetCurrentWindow)->cellView (list "text" "drawing") (list (list ' ...
                      num2str(xx*delta) ' ' num2str((yy)*delta) ...
                ') (list ' ... 
                num2str((xx+1)*delta) ' ' num2str((yy+1)*delta) ...
                       ')))\n'];
            %% disp(cmdStr);
            fprintf(fid, cmdStr);
            
        end;
    end;

    close(fid);
              
