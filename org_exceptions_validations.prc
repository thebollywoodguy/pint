DROP PROCEDURE PINTEXT.ORG_EXCEPTIONS_VALIDATIONS;

CREATE OR REPLACE PROCEDURE PINTEXT.org_exceptions_validations  
as 

v_count number;
v_employeeid number;
v_previouspod number;
v_currentpod number;
v_terminationdate number;
v_leavestartdate number;
v_leaveenddate number;
v_onpaidleave number;
v_okrpod number;
v_localpod number;
v_globalpod number;
v_titlename number;
v_podeffdate number;
v_vceffdate number;
v_localpodquota number;
v_globalpodquota number;
v_currentquota number;
v_okrquota number;
v_sql varchar2(5000);
v_errormsg varchar2(5000);
v_valid number;
v_intermsg varchar2(255);

cursor c1 is
select * from org_exceptions_hold;


begin

delete from org_exception_errors;

commit;

 FOR validate_rec IN c1
 
  LOOP
  
  v_sql:= 'select count(*) from org_exceptions_hold where  employee_id = '||validate_rec.employee_id;
  
execute immediate v_sql into v_count;

if v_count < 2 then 

v_sql := 'SELECT VALIDATE_CONVERSION(employee_id as number)   FROM org_exceptions_hold where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into v_employeeid;

v_sql := 'SELECT VALIDATE_CONVERSION(nvl(leave_end_date,''01/01/2200'') as date, ''mm/dd/yyyy'')   FROM org_exceptions_hold where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into v_leaveenddate;

v_sql := 'SELECT VALIDATE_CONVERSION(nvl(termination_Date,''01/01/2200'') as date, ''mm/dd/yyyy'')   FROM org_exceptions_hold where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into v_terminationdate; 


v_sql := 'SELECT VALIDATE_CONVERSION(nvl(leave_start_date,''01/01/2200'') as date, ''mm/dd/yyyy'')   FROM org_exceptions_hold where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into v_leavestartdate; 

v_sql:= 'SELECT VALIDATE_CONVERSION(ON_PAID_LEAVE as number)  FROM org_exceptions_hold  where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into  v_onpaidleave;

v_sql:= 'SELECT VALIDATE_CONVERSION(nvl(pod_eff_startdate,''01/01/2200'') as date, ''mm/dd/yyyy'')  FROM org_exceptions_hold   where employee_id = '||validate_rec.employee_id;

execute immediate v_sql  into v_podeffdate;

v_sql:= 'SELECT VALIDATE_CONVERSION(nvl(vc_eff_startdate,''01/01/2200'') as date, ''mm/dd/yyyy'') FROM org_exceptions_hold   where employee_id = '||validate_rec.employee_id;

execute immediate v_sql  into v_vceffdate;

v_sql:= 'SELECT VALIDATE_CONVERSION(localpod_quota as number)  FROM org_exceptions_hold   where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into v_localpodquota;

v_sql:= 'SELECT VALIDATE_CONVERSION(globalpod_quota as number)  FROM org_exceptions_hold   where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into v_globalpodquota;

v_sql:= 'SELECT VALIDATE_CONVERSION(currentpod_quota as number)  FROM org_exceptions_hold   where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into v_currentquota;

v_sql:= 'SELECT VALIDATE_CONVERSION(okrpod_quota as number)  FROM org_exceptions_hold   where employee_id = '||validate_rec.employee_id;

execute immediate v_sql into v_okrquota;

if nvl(trim(validate_rec.current_pod),'0') <> '0' then 

begin 
v_sql :='select case when val <> ''0'' then 0 else 1 end  from (
    select nvl( (select nvl(current_pod,0) val from (
       select * from (SELECT distinct employee_id, trim(regexp_substr(current_pod, ''[^;]+'', 1, level)) current_pod
                                                                                      FROM (SELECT employee_id,nvl(trim(current_pod),''x'') current_pod,nvl(trim(okr_pod),''x''),nvl(trim(local_pod),''x''),nvl(trim(global_pod),''x'') FROM org_exceptions_hold 
                                                                                      where employee_id =   '||validate_rec.employee_id ||'  ) t
                                                                                    CONNECT BY instr(current_pod, '';'', 1, level - 1) > 0) o                                                                                    
            where  o.employee_id =   '||validate_rec.employee_id ||'   and not exists (select 1 from nq_podquota n where ( N.NEXTQUARTERCHANNEL = o.current_pod or N.NEXTQUARTERSUBCHANNEL = o.current_pod or N.NEXTQUARTERSECTOR = o.current_pod 
                                                                                        or N.NEXTQUARTERSUBSECTOR = o.current_pod or N.NEXTQUARTERMANAGERTEAM = o.current_pod or N.NEXTQUARTERTEAMNAME = o.current_pod))
)),0) val from dual)';



/* 'select case when val <> ''0'' then 1 else 0 end  from (
    select nvl((select nvl(current_pod,0) val from (SELECT distinct employee_id, trim(regexp_substr(current_pod, ''[^;]+'', 1, level)) current_pod
                                                                                      FROM (SELECT employee_id,current_pod,okr_pod,local_pod,global_pod FROM org_exceptions_hold) t
                                                                                    CONNECT BY instr(current_pod, '';'', 1, level - 1) > 0) o 
            where  o.employee_id =  '||validate_rec.employee_id ||'  and exists (select 1 from nq_podquota n where ( N.NEXTQUARTERCHANNEL = o.current_pod or N.NEXTQUARTERSUBCHANNEL = o.current_pod or N.NEXTQUARTERSECTOR = o.current_pod 
                                                                                        or N.NEXTQUARTERSUBSECTOR = o.current_pod or N.NEXTQUARTERMANAGERTEAM = o.current_pod or N.NEXTQUARTERTEAMNAME = o.current_pod))),0) val from dual)' ;
*/
insert into test1 values (v_sql);

commit;

execute immediate v_sql into v_currentpod;

if v_currentpod <> 0 then v_currentpod:=1; else v_currentpod:=0; end if;
end ;

else v_currentpod:=2;
end if;

if nvl(trim(validate_rec.previous_pod),'0') <> '0' then 

v_sql := 'select case when val <> ''0'' then 1 else 0 end  from (
    select nvl((select nvl(previous_pod,0) val from org_exceptions_hold o 
            where o.employee_id =  '||validate_rec.employee_id ||'  and exists (select 1 from nq_podquota n where ( N.NEXTQUARTERCHANNEL = o.current_pod or N.NEXTQUARTERSUBCHANNEL = o.current_pod or N.NEXTQUARTERSECTOR = o.current_pod 
                                                                                        or N.NEXTQUARTERSUBSECTOR = o.current_pod or N.NEXTQUARTERMANAGERTEAM = o.current_pod or N.NEXTQUARTERTEAMNAME = o.current_pod))),0) val from dual)' ;

execute immediate v_sql into v_previouspod;

if v_previouspod <> 0 then v_previouspod:=1; else v_previouspod:=0; end if;

else v_previouspod:=2; end if;

if nvl(trim(validate_rec.okr_pod),'0') <> '0' then 
v_sql := 'select case when val <> ''0'' then 0 else 1 end  from (
    select nvl( (select nvl(okr_pod,0) val from (
       select * from (SELECT distinct employee_id, trim(regexp_substr(okr_pod, ''[^;]+'', 1, level)) okr_pod
                                                                                      FROM (SELECT employee_id,nvl(trim(current_pod),''x'') current_pod,nvl(trim(okr_pod),''x'') okr_pod,nvl(trim(local_pod),''x''),nvl(trim(global_pod),''x'') FROM org_exceptions_hold 
                                                                                      where employee_id =   '||validate_rec.employee_id ||'  ) t
                                                                                    CONNECT BY instr(okr_pod, '';'', 1, level - 1) > 0) o                                                                                    
            where  o.employee_id =   '||validate_rec.employee_id ||'   and not exists (select 1 from nq_podquota n where ( N.NEXTQUARTERCHANNEL = o.okr_pod or N.NEXTQUARTERSUBCHANNEL = o.okr_pod or N.NEXTQUARTERSECTOR = o.okr_pod 
                                                                                        or N.NEXTQUARTERSUBSECTOR = o.okr_pod or N.NEXTQUARTERMANAGERTEAM = o.okr_pod or N.NEXTQUARTERTEAMNAME = o.okr_pod))
)),0) val from dual)' ;

execute immediate v_sql into v_intermsg;

if v_intermsg <> '0' then v_okrpod:=1; else v_okrpod:=0; end if;

 else v_okrpod:=2; end if;

if nvl(trim(validate_rec.local_pod),'0') <> '0' then
v_sql := 'select case when val <> ''0'' then 0 else 1 end  from (
    select nvl( (select nvl(local_pod,0) val from (
       select * from (SELECT distinct employee_id, trim(regexp_substr(local_pod, ''[^;]+'', 1, level)) local_pod
                                                                                      FROM (SELECT employee_id,nvl(trim(current_pod),''x'') current_pod,nvl(trim(okr_pod),''x'') okr_pod,nvl(trim(local_pod),''x'') local_pod,nvl(trim(global_pod),''x'') FROM org_exceptions_hold 
                                                                                      where employee_id =   '||validate_rec.employee_id ||'  ) t
                                                                                    CONNECT BY instr(local_pod, '';'', 1, level - 1) > 0) o                                                                                    
            where  o.employee_id =   '||validate_rec.employee_id ||'   and not exists (select 1 from nq_podquota n where ( N.NEXTQUARTERCHANNEL = o.local_pod or N.NEXTQUARTERSUBCHANNEL = o.local_pod or N.NEXTQUARTERSECTOR = o.local_pod 
                                                                                        or N.NEXTQUARTERSUBSECTOR = o.local_pod or N.NEXTQUARTERMANAGERTEAM = o.local_pod or N.NEXTQUARTERTEAMNAME = o.local_pod))
)),0) val from dual)' ;

execute immediate v_sql into v_intermsg;

if v_intermsg <> '0' then v_localpod:=1; else v_localpod:=0; end if;

 else v_localpod:=2; end if;


if nvl(trim(validate_rec.global_pod),'0') <> '0' then
v_sql := 'select case when val <> ''0'' then 0 else 1 end  from (
    select nvl( (select nvl(global_pod,0) val from (
       select * from (SELECT distinct employee_id, trim(regexp_substr(global_pod, ''[^;]+'', 1, level)) global_pod
                                                                                      FROM (SELECT employee_id,nvl(trim(current_pod),''x'') current_pod,nvl(trim(okr_pod),''x'') okr_pod,nvl(trim(local_pod),''x'') local_pod,nvl(trim(global_pod),''x'') global_pod FROM org_exceptions_hold 
                                                                                      where employee_id =   '||validate_rec.employee_id ||'  ) t
                                                                                    CONNECT BY instr(global_pod, '';'', 1, level - 1) > 0) o                                                                                    
            where  o.employee_id =   '||validate_rec.employee_id ||'   and not exists (select 1 from nq_podquota n where ( N.NEXTQUARTERCHANNEL = o.global_pod or N.NEXTQUARTERSUBCHANNEL = o.global_pod or N.NEXTQUARTERSECTOR = o.global_pod 
                                                                                        or N.NEXTQUARTERSUBSECTOR = o.global_pod or N.NEXTQUARTERMANAGERTEAM = o.global_pod or N.NEXTQUARTERTEAMNAME = o.global_pod))
)),0) val from dual)' ;


insert into test1 values (v_sql);

commit;


execute immediate v_sql into v_intermsg;

if v_intermsg <> '0' then v_globalpod:=1; else v_globalpod:=0; end if;

else v_globalpod:=2; end if;

if nvl(trim(validate_rec.title_name),'0') <> '0' then
v_sql := 'select case when val <> ''0'' then 1 else 0 end  from (
    select nvl((select nvl(title_name,0) val from org_exceptions_hold o 
            where o.employee_id =  '||validate_rec.employee_id ||'  and exists (select 1 from cs_title tl where tl.removedate > sysdate and tl.name = o.title_name)),0) val from dual)' ;

execute immediate v_sql into v_intermsg;

if v_intermsg <> '0' then v_titlename:=1; else v_titlename:=0; end if;

else v_titlename:=2; end if;

 
v_sql := 'select case when ('||v_count||' <> 1 or '||v_employeeid||' = 0 or '||v_previouspod||' = 0 or '||v_currentpod||' =0 or '||v_terminationdate||' = 0 or '||v_leavestartdate||' = 0 or '|| v_leaveenddate||'= 0 or '||v_onpaidleave||'= 0 or '||v_okrpod||'= 0 or '||v_localpod||'= 0 or  
                            '||v_globalpod||'= 0 or '||v_titlename||' = 0 or '||v_podeffdate||'= 0 or '|| v_vceffdate||'= 0 or '||v_localpodquota||'= 0 or '||v_globalpodquota||'= 0 or '||v_currentquota||'= 0 or '||v_okrquota||' = 0) 
                            then 0 else 1 end from dual' ;  


execute immediate v_sql into v_valid;

if v_valid = 0 then 

v_sql :='select case when '||v_employeeid||' = 0 then ''EmpID'' else null end || 
                        case when '||v_previouspod||' = 0 then ''Previous Pod'' else null end || 
                               case when   '||v_currentpod||' =0 then ''CurrentPod'' else null end ||
                                 case when   '||v_terminationdate||' = 0 then ''TermDate'' else null end ||
                                 case when   '||v_leavestartdate||' = 0 then ''Leavestdate'' else null end ||
                                 case when   '|| v_leaveenddate||'= 0 then ''LeaveEnddate'' else null end ||
                                  case when   '||v_onpaidleave||'= 0 then ''paidleave'' else null end ||
                                  case when    '||v_okrpod||'= 0 then ''OkrPod'' else null end ||
                                   case when   '||v_localpod||'= 0 then ''LocalPod'' else null end ||
                            case when  '||v_globalpod||'= 0 then ''GlobalPod'' else null end ||
                            case when   '||v_titlename||' = 0 then ''Titlename''  else null end ||
                             case when   '||v_podeffdate||'= 0  then ''Podeffdate''  else null end ||
                              case when  '|| v_vceffdate||'= 0 then ''vceffdate''  else null end ||
                              case when   '||v_localpodquota||'= 0 then ''localquota''  else null end ||
                              case when    '||v_globalpodquota||'= 0 then ''globalquota''  else null end ||
                                case when   '||v_currentquota||'= 0 then ''currentquota''  else null end ||
                                case when    '||v_okrquota||' = 0 then ''Okrquota''  else null end ||
                                ''is invalid'' from dual'; 
                            
execute immediate v_sql into v_errormsg;

    insert into org_exception_errors values (validate_rec.employee_id,
                                                                 validate_rec.previous_pod ,
                                                                 validate_rec.current_pod ,
                                                                 validate_rec.termination_date ,
                                                                 validate_rec.leave_start_Date ,
                                                                 validate_rec.leave_end_date ,
                                                                 validate_rec.on_paid_leave ,
                                                                 validate_rec.okr_pod,
                                                                 validate_rec.local_pod,
                                                                 validate_rec.global_pod ,
                                                                 validate_rec.title_name ,
                                                                 validate_rec.pod_eff_startdate ,
                                                                 validate_rec.vc_eff_startdate ,
                                                                 validate_rec.localpod_quota ,
                                                                 validate_rec.globalpod_quota ,
                                                                 validate_rec.currentpod_quota,
                                                                 validate_rec.okrpod_quota , 'Failed', v_errormsg);
                                                                 
commit; 
end if;
else 
       v_sql :='select case when '||v_count||' <> 1 then ''Employee repeated multiple times'' else null end from dual';
       
       execute immediate v_sql into v_errormsg;

    insert into org_exception_errors values (validate_rec.employee_id,
                                                                 validate_rec.previous_pod ,
                                                                 validate_rec.current_pod ,
                                                                 validate_rec.termination_date ,
                                                                 validate_rec.leave_start_Date ,
                                                                 validate_rec.leave_end_date ,
                                                                 validate_rec.on_paid_leave ,
                                                                 validate_rec.okr_pod,
                                                                 validate_rec.local_pod,
                                                                 validate_rec.global_pod ,
                                                                 validate_rec.title_name ,
                                                                 validate_rec.pod_eff_startdate ,
                                                                 validate_rec.vc_eff_startdate ,
                                                                 validate_rec.localpod_quota ,
                                                                 validate_rec.globalpod_quota ,
                                                                 validate_rec.currentpod_quota,
                                                                 validate_rec.okrpod_quota , 'Failed', v_errormsg);
                                                                 
                                                                 commit;
                                                          
        end if;                   

       END LOOP;


end;
/
