--records=all
--tab=before
select * from ee_repayment_funding where id=529416;
select *
  from claim_offset_dtl cod
 where cod.ee_repay_fund_id in (529416);
select *
  from elct_offset_dtl cod
 where cod.ee_repay_fund_id in (529416);
declare
  cOtherMessage   VARCHAR2(4000);
  cErrorArea      VARCHAR2(1000);
  cResult         VARCHAR2(1000);
  cErrorcategory  VARCHAR2(4000);
  nErrorcode      NUMBER;
  cIsDebitCardClm VARCHAR2(3) := 'Yes';
  -- Exception
  eException      EXCEPTION;
  tEeRepaymentRec Ee_Repayment_Funding%ROWTYPE;
BEGIN
  UPDATE vw_appsession v
     SET v.LAST_CHANGE_BY   = user || '.' ||
                              (select sys_context('USERENV', 'OS_USER')
                                 from dual),
         v.LAST_CHANGE_THRU = 'HLP-122260';

  for i in (select id FROM ee_repayment_funding WHERE id in (529416)) loop
    SELECT *
      INTO tEeRepaymentRec
      FROM ee_repayment_funding
     WHERE id = i.id;
  
     delete plan_sponsor_report_dtl t1 where t1.ee_repay_fund_id = i.id;
    dbms_output.put_line('Deleted rows from plan_sponsor_report_dtl : ' ||
                         sql%rowcount);
  
    IF tEeRepaymentRec.instr_amt <> tEeRepaymentRec.fund_balance THEN
      IF Coalesce(tEeRepaymentRec.Trxn_Type, 'Repayment') =
         'HSA Overpayment Repayment' THEN
        cErrorArea := 'HSARepaymentReversal(' ||
                      to_char(tEeRepaymentRec.id) || ')';
        Repayment_Util.HSARecoveryReversal(ocResult         => cResult,
                                           ocErrorArea      => cErrorArea,
                                           ocErrorcategory  => cErrorcategory,
                                           ocOtherMessage   => cOtherMessage,
                                           onerrorcode      => nErrorcode,
                                           itEeRepaymentRec => tEeRepaymentRec);
        IF cResult <> 'OK' THEN
          RAISE eException;
        END IF;
      
      ELSE
        cErrorArea := 'NonHSARepaymentReversal(' ||
                      to_char(tEeRepaymentRec.id) || ')';
        Repayment_Util.NonHSARepaymentReversal(ocResult         => cResult,
                                               ocErrorArea      => cErrorArea,
                                               ocerrorcategory  => cErrorcategory,
                                               ocOtherMessage   => cOtherMessage,
                                               onerrorcode      => nErrorcode,
                                               ocIsDebitCardClm => cIsDebitCardClm,
                                               itEeRepaymentRec => tEeRepaymentRec);
        IF cResult <> 'OK' THEN
          RAISE eException;
        END IF;
      END IF;
    
    END IF;
    update ee_repayment_funding efd
      set efd.status       = 'Created',
          efd.fund_balance = efd.amt_used,
          --efd.refunded_amt = 0,
          efd.amt_used = 0 , 
          efd.initiate_refund_on = sysdate-3
    where efd.id = i.id
      and efd.status != 'Created';
  
   
  
    dbms_output.put_line('Rows updated funding : ' || sql%rowcount);
    
     
  end loop;

  UPDATE vw_appsession v
     SET v.LAST_CHANGE_BY = null, v.LAST_CHANGE_THRU = null;
exception
  WHEN eException THEN
    cResult := 'ERROR';
    dbms_output.put_line('Error: in reversal : ' || cOtherMessage);
  when others then
    dbms_output.put_line('Error: ' || sqlerrm);
end;
/
--tab=after
select * from ee_repayment_funding where id=529416;
select *
  from claim_offset_dtl cod
 where cod.ee_repay_fund_id in (529416);
select *
  from elct_offset_dtl cod
 where cod.ee_repay_fund_id in (529416);
