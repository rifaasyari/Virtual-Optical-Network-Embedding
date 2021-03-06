function [ success_final ,  V_sub  , E_sub_slot , SubSlot ] = CI_linkMap( bestNode , V_v , E_v , V_sub , E_sub , E_sub_slot )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

    global N;
    slot_backup=E_sub_slot;
    occupiedSlot=0;
    throughNode=[];
    [ ln , col , value ] = find(tril(E_v));
    success=[];
    linkFlag=ones(size(V_sub,2),size(V_sub,2));%use to flag occupied link
    for i=1:size(ln,1)
        E_sub=E_sub.*linkFlag;
        [dist,path,pred] = graphshortestpath(sparse(E_sub),bestNode(ln(i)),bestNode(col(i)),'directed',false)
        bool=0;
    
        path = get_path(path , E_v(ln(i),col(i)) ,bestNode(ln(i)) , bestNode(col(i)) , V_v , E_v , V_sub , E_sub , E_sub_slot);
        %first fit
        for j=1:N-E_v(ln(i),col(i))+1
            %judge slot
            bool=1;
            for k=1:size(path,2)-1
               if(sum(E_sub_slot(path(k),path(k+1),j:j+E_v(ln(i),col(i))-1))~=E_v(ln(i),col(i))) 
                   bool=0;
               end
            end
            if(bool==1)
                break;
            end
        end
        
        success=[success,bool];
        if(bool==1)
            %erase occupied slot and link
            for m=1:size(path,2)-1
                for n=j:j+E_v(ln(i),col(i))-1
                    E_sub_slot(path(m),path(m+1),n)=0;
                    E_sub_slot(path(m+1),path(m),n)=0;
                end
            end

            linkFlag(path(m),path(m+1))=0;
            linkFlag(path(m+1),path(m))=0;
        end
        occupiedSlot=occupiedSlot+dist*E_v(ln(i),col(i));
        throughNode=[throughNode getPathNode(path)];
    end

    if(sum(success)==size(success,2))
        for i=1:size(bestNode,2)
            V_sub(bestNode(i))=V_sub(bestNode(i))-V_v(i);
        end
        SubSlot=slot_backup-E_sub_slot;
        success_final=1;
    else
        E_sub_slot=slot_backup;
        success_final=0;
        SubSlot=[];
    end

end

