-------------------------------------------------------------------------------
--
-- Script:	trace_waits.sql
-- Purpose:	to trace sessions waiting for a resource
--
-- Copyright:	(c) 1998 Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
prompt
prompt This script uses event 10046, level 8 to trace the event waits in
prompt the top N sessions affected by waits for a particular resource.
prompt
accept Event    prompt "Select sessions waiting for: "
accept Sessions prompt "Number of sessions to trace: "
accept Sleep    prompt "Seconds to leave tracing on: "
prompt
prompt Tracing ... Please wait ...
set verify off
set serveroutput on

declare
  type sid_type is table of number index by binary_integer;
  type serial_type is table of number index by binary_integer;
  cursor waiters is
    select
      e.sid,
      s.serial#
    from
      sys.v_$session_event  e,
      sys.v_$session  s
    where
      e.event = '&Event' and
      s.sid = e.sid
    order by
      total_waits desc;
  sid sid_type;
  serial serial_type;
  n binary_integer := 0;
begin
  open waiters;
  loop
    n := n + 1;
    exit when n = &Sessions + 1;
    fetch waiters into sid(n), serial(n);
    exit when waiters%notfound;   
    sys.dbms_system.set_ev(sid(n), serial(n), 10046, 8, '');
  end loop;
  if n > 1 then
    sys.dbms_lock.sleep(&Sleep);
    loop
      n := n - 1;
      exit when n = 0;
      sys.dbms_system.set_ev(sid(n), serial(n), 10046, 0, '');
    end loop;
  else
    sys.dbms_output.put_line('No sessions to trace.');
  end if;
end;   
/
