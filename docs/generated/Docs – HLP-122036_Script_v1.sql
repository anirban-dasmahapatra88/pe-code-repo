<html>
<body>
<h1>HLP-122036_Script_v1.sql</h1>
<hr/>
<html>
  <body style="font-family:Segoe UI, Arial, sans-serif; color:#23234a; line-height:1.6; background:#fafbfc;">

    <!-- Header -->
    <div style="padding:18px 20px; background:#eae6f7; border-left:6px solid #6c3ebc; margin-bottom:20px;">
      <h1 style="margin:0; font-size:24px; color:#3a237a;">Documentation: HLP-122036_Script_v1.sql</h1>
      <p style="margin:4px 0 0; font-size:14px; color:#5a5a5a;">
        Auto‑generated technical documentation for code review, knowledge sharing, and repository reference.
      </p>
    </div>

    <!-- Section: Overview -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">1. Overview</h2>
    <p>
      This document provides a structured explanation of the file <strong>HLP-122036_Script_v1.sql</strong>. It describes the purpose of the code, key parameters, usage examples, dependencies, and other relevant technical notes.
    </p>

    <!-- Section: Purpose -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">2. Purpose</h2>
    <p>
      The script is designed to reset specific fields in the <strong>debit_card_event_capture</strong> table for records with status 'Created', a non-null <strong>process_run_id</strong>, and <strong>event_type</strong> 'ClaimSync'. It also updates session tracking fields in <strong>Vw_Appsession</strong> for audit purposes.
    </p>

    <!-- Section: Parameters / Inputs -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">3. Parameters / Inputs</h2>
    <ul style="margin-left:20px;">
      <li><strong>status</strong>: Filters records with value 'Created'.</li>
      <li><strong>process_run_id</strong>: Must be non-null for update/reset.</li>
      <li><strong>event_type</strong>: Filters records with value 'ClaimSync'.</li>
      <li><strong>id</strong>: Used in post-update validation.</li>
    </ul>

    <!-- Section: Control Validation SQLs -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">4. Control Validation SQLs</h2>
    <p>
      <strong>Positive Scenario:</strong> Data meets criteria and is updated/reset as expected.
    </p>
    <div style="background:#f7f7f7; border:1px solid #ddd; padding:12px; border-radius:4px; font-family:Consolas,monospace; white-space:pre-wrap;">
-- Example Data
insert into debit_card_event_capture (id, status, process_run_id, event_type) values (20001, 'Created', 12345, 'ClaimSync');

-- Validation SQL (Before Update)
select * from debit_card_event_capture where status='Created' and process_run_id is not null and event_type='ClaimSync';

-- Run Script

-- Validation SQL (After Update)
select * from debit_card_event_capture where status='Created' and process_run_id is null and event_type='ClaimSync' and id=20001;
    </div>
    <p>
      <strong>Negative Scenario:</strong> Data does not meet criteria; no update occurs.
    </p>
    <div style="background:#f7f7f7; border:1px solid #ddd; padding:12px; border-radius:4px; font-family:Consolas,monospace; white-space:pre-wrap;">
-- Example Data
insert into debit_card_event_capture (id, status, process_run_id, event_type) values (20002, 'Processed', null, 'ClaimSync');

-- Validation SQL (Before Update)
select * from debit_card_event_capture where status='Created' and process_run_id is not null and event_type='ClaimSync';

-- Run Script

-- Validation SQL (After Update)
select * from debit_card_event_capture where id=20002 and process_run_id is null;
-- No rows should be returned, confirming no update.
    </div>

    <!-- Section: Example Usage -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">5. Example Usage</h2>
    <p>The following is an example demonstrating typical usage of the implemented logic:</p>
    <div style="background:#f7f7f7; border:1px solid #ddd; padding:12px; border-radius:4px; font-family:Consolas,monospace; white-space:pre-wrap;">
--tab=before
select * from debit_card_event_capture where status='Created' and process_run_id is not null and event_type='ClaimSync';
Begin
  Update Vw_Appsession v
     Set v.Last_Change_By   = user,
         v.Last_Change_Thru = 'HLP-107535-Script_' || to_Char(sysdate, 'ddMonYYYY');
 
  update debit_card_event_capture ddc set ddc.status='Created',ddc.process_run_id=null,ddc.process_log_id=null,ddc.queued_on=null
   where status='Created' and process_run_id is not null and event_type='ClaimSync';
  
  dbms_output.put_line('No of rows updated is: ' || sql%rowcount);
  Update Vw_Appsession v
     Set v.Last_Change_By = null, v.Last_Change_Thru = null;
End;
/
--tab=after
select * from debit_card_event_capture where status='Created' and event_type='ClaimSync' and id in (13611033,13611040,13407886,12663777,12663375);
    </div>

    <!-- Section: Dependencies -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">6. Dependencies</h2>
    <ul style="margin-left:20px;">
      <li>Oracle Database</li>
      <li>debit_card_event_capture table</li>
      <li>Vw_Appsession view</li>
      <li>DBMS_OUTPUT package</li>
    </ul>

    <!-- Section: Code Improvement Suggestions -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">7. Code Improvement Suggestions</h2>
    <ul style="margin-left:20px;">
      <li>
        <strong>Suggestion:</strong> Use explicit transaction control and error handling for reliability.
        <br/>
        <strong>Explanation:</strong> The current script does not handle exceptions or commit/rollback. Adding transaction control ensures data integrity and proper error reporting.
      </li>
      <li>
        <strong>Suggestion:</strong> Minimize session updates to only affected sessions.
        <br/>
        <strong>Explanation:</strong> The script updates all sessions, which may not be necessary. Target only relevant sessions for better performance.
      </li>
      <li>
        <strong>Suggestion:</strong> Add logging for audit and troubleshooting.
        <br/>
        <strong>Explanation:</strong> Logging affected record IDs and errors improves traceability.
      </li>
    </ul>
    <div style="background:#f7f7f7; border:1px solid #ddd; padding:12px; border-radius:4px; font-family:Consolas,monospace; white-space:pre-wrap;">
-- Improved Script Example
DECLARE
  v_rows_updated NUMBER;
BEGIN
  -- Update session only for relevant users (example: current user)
  UPDATE Vw_Appsession v
    SET v.Last_Change_By = USER,
        v.Last_Change_Thru = 'HLP-107535-Script_' || TO_CHAR(SYSDATE, 'ddMonYYYY')
    WHERE v.User_Name = USER;

  -- Update debit_card_event_capture
  UPDATE debit_card_event_capture ddc
    SET ddc.status = 'Created',
        ddc.process_run_id = NULL,
        ddc.process_log_id = NULL,
        ddc.queued_on = NULL
    WHERE status = 'Created'
      AND process_run_id IS NOT NULL
      AND event_type = 'ClaimSync';

  v_rows_updated := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('No of rows updated is: ' || v_rows_updated);

  -- Reset session fields
  UPDATE Vw_Appsession v
    SET v.Last_Change_By = NULL,
        v.Last_Change_Thru = NULL
    WHERE v.User_Name = USER;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
-- Data Scenario Example
-- Insert test data, run script, validate updates and error handling.
    </div>

    <!-- Section: Notes -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">8. Notes</h2>
    <ul style="margin-left:20px;">
      <li>Ensure only relevant records are updated to avoid unintended data changes.</li>
      <li>Performance may be impacted if tables are large; consider batch processing.</li>
      <li>Exception handling and transaction control are recommended for production scripts.</li>
      <li>Enhancements can include parameterization and audit logging.</li>
    </ul>

    <!-- Section: Summary -->
    <h2 style="color:#6c3ebc; border-bottom:2px solid #d6d1e7; padding-bottom:6px;">9. Summary</h2>
    <p>
      <strong>HLP-122036_Script_v1.sql</strong> is a critical script for resetting event capture records and session tracking. The documentation provides validation SQLs, improvement suggestions, and technical notes to support maintainability and operational reliability.
    </p>

  </body>
</html>
</body>
</html>