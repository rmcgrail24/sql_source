SELECT b, account
FROM ledger
MODEL  IGNORE NAV 
  DIMENSION BY (account)   
  MEASURES (balance b) 
  RULES ITERATE (100)  
    UNTIL ( ABS( (PREVIOUS(b['Net']) -  b['Net']) ) <  0.01 ) (
    b['Net'] = b['Salary'] - b['Interest'] - b['Tax'],
    b['Tax'] = (b['Salary'] - b['Interest']) * 0.38 + 
                b['Capital_gains'] *0.28,
    b['Interest'] = b['Net'] * 0.30,
    b['Iteration Count']= ITERATION_NUMBER + 1
      -- the '+1' is needed because the ITERATION_NUMBER starts at 0
  )
/
