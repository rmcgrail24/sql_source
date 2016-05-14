-------------------------------------------------------------------------------
--
-- Script:	latch_types.sql
-- Purpose:	shows the latch types by number (with child counts)
-- For:		up to 7.3
--
-- Copyright:	(c) 1998 Ixora Pty Ltd
-- Author:	Steve Adams
--
-------------------------------------------------------------------------------
@reset_sqlplus

column type_num format 999 heading "TYPE|NUMBER"
column type_name format a40 heading "TYPE|NAME"
column parent format 9 heading "PARENT|LATCH"
column children format 999999 heading "CHILD|LATCHES"

select
  l.kslltnum  type_num,
  d.kslldnam  type_name,
  sum(decode(l.kslltcnm, 0, 1, null))  parent,
  sum(decode(l.kslltcnm, 0, null, 1))  children
from
  sys.x_$kslld  d,
  sys.x_$ksllt  l
where
  l.kslltnum = d.indx
group by
  l.kslltnum,
  d.kslldnam
order by
  l.kslltnum,
  d.kslldnam
/

@reset_sqlplus
