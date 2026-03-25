<html>
<body>
<h1>HLP-122036_Script_v1.sql</h1>
<hr/>
<html>
  <body style="font-family:Segoe UI, Arial, sans-serif; color:#23234a; line-height:1.6; background:#fafbfc;">

    <!-- Header -->
    <div style="padding:18px 20px; background:#eae6f7; border-left:6px solid #7A4CB1; margin-bottom:20px;">
      <h1 style="margin:0; font-size:24px; color:#4A2E8E;">Documentation: HLP-122036_Script_v1.sql</h1>
      <p style="margin:4px 0 0; font-size:14px; color:#5a5a5a;">
        Auto‑generated technical documentation for code review, knowledge sharing, and repository reference.
      </p>
    </div>

    <!-- Section: Overview -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">1. Overview</h2>
    <p>
      This document provides a structured explanation of the file <strong>HLP-122036_Script_v1.sql</strong>. It describes the purpose of the code, key parameters, usage examples, dependencies, and other relevant technical notes.
    </p>

    <!-- Section: Purpose -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">2. Purpose</h2>
    <p>
      The script is designed to reset specific fields in the <strong>debit_card_event_capture</strong> table for records with status 'Created', a non-null <strong>process_run_id</strong>, and <strong>event_type</strong> 'ClaimSync'. It also updates session tracking fields in <strong>Vw_Appsession</strong> for audit purposes.
    </p>

    <!-- Section: Parameters / Inputs -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">3. Parameters / Inputs</h2>
    <ul style="margin-left:20px;">
      <li><strong>status</strong>: Should be 'Created' for affected rows.</li>
      <li><strong>process_run_id</strong>: Must be not null for update eligibility.</li>
      <li><strong>event_type</strong>: Must be 'ClaimSync' for update eligibility.</li>
      <li><strong>id</strong>: Used for filtering in post-update validation.</li>
    </ul>

    <!-- Section: Control Validation SQLs -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">4. Control Validation SQLs</h2>
    <p>
      Below are SQLs for validating the script's effect, with positive and negative scenarios and sample data.
    </p>
    <div style="background:#f7f7f7; border:1px solid #ddd; padding:12px; border-radius:4px; font-family:Consolas,monospace; white-space:pre-wrap;">
-- Positive Scenario: Data before update
SELECT * FROM debit_card_event_capture
WHERE status = 'Created'
  AND process_run_id IS NOT NULL
  AND event_type = 'ClaimSync';

-- Example Data:
-- id        status    process_run_id    event_type
-- 13611033  Created   1001              ClaimSync
-- 13611040  Created   1002              ClaimSync

-- Negative Scenario: Data not eligible for update
SELECT * FROM debit_card_event_capture
WHERE (status != 'Created' OR process_run_id IS NULL OR event_type != 'ClaimSync');

-- Example Data:
-- id        status    process_run_id    event_type
-- 13407886  Pending   NULL              ClaimSync
-- 12663777  Created   NULL              OtherType

-- Post-update Validation: Data after update
SELECT * FROM debit_card_event_capture
WHERE status = 'Created'
  AND event_type = 'ClaimSync'
  AND id IN (13611033, 13611040, 13407886, 12663777, 12663375);

-- Expected: process_run_id, process_log_id, queued_on should be NULL for updated rows.
    </div>

    <!-- Section: Example Usage -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">5. Example Usage</h2>
    <p>
      Typical usage involves running the script to reset processing fields for 'ClaimSync' events, followed by validation queries to confirm the update.
    </p>
    <div style="background:#f7f7f7; border:1px solid #ddd; padding:12px; border-radius:4px; font-family:Consolas,monospace; white-space:pre-wrap;">
--tab=before
SELECT * FROM debit_card_event_capture WHERE status='Created' AND process_run_id IS NOT NULL AND event_type='ClaimSync';

BEGIN
  UPDATE Vw_Appsession v
     SET v.Last_Change_By   = USER,
         v.Last_Change_Thru = 'HLP-107535-Script_' || TO_CHAR(SYSDATE, 'ddMonYYYY');

  UPDATE debit_card_event_capture ddc
     SET ddc.status='Created',
         ddc.process_run_id=NULL,
         ddc.process_log_id=NULL,
         ddc.queued_on=NULL
   WHERE status='Created'
     AND process_run_id IS NOT NULL
     AND event_type='ClaimSync';

  DBMS_OUTPUT.PUT_LINE('No of rows updated is: ' || SQL%ROWCOUNT);

  UPDATE Vw_Appsession v
     SET v.Last_Change_By = NULL,
         v.Last_Change_Thru = NULL;
END;
/
--tab=after
SELECT * FROM debit_card_event_capture WHERE status='Created' AND event_type='ClaimSync' AND id IN (13611033,13611040,13407886,12663777,12663375);
    </div>

    <!-- Section: Dependencies -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">6. Dependencies</h2>
    <ul style="margin-left:20px;">
      <li>Oracle Database (PL/SQL)</li>
      <li>debit_card_event_capture table</li>
      <li>Vw_Appsession view</li>
      <li>DBMS_OUTPUT package</li>
    </ul>

    <!-- Section: Code Improvement Suggestions -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">7. Code Improvement Suggestions</h2>
    <ul style="margin-left:20px;">
      <li>
        <strong>Suggestion:</strong> Use explicit transaction control and error handling for reliability.
        <br/>
        <strong>Explanation:</strong> The current script lacks exception handling and transaction control, which may lead to partial updates or untracked failures.
      </li>
      <li>
        <strong>Modified Code:</strong>
        <div style="background:#f7f7f7; border:1px solid #ddd; padding:12px; border-radius:4px; font-family:Consolas,monospace; white-space:pre-wrap;">
DECLARE
  v_rows_updated NUMBER;
BEGIN
  UPDATE Vw_Appsession v
     SET v.Last_Change_By   = USER,
         v.Last_Change_Thru = 'HLP-107535-Script_' || TO_CHAR(SYSDATE, 'ddMonYYYY');

  UPDATE debit_card_event_capture ddc
     SET ddc.status='Created',
         ddc.process_run_id=NULL,
         ddc.process_log_id=NULL,
         ddc.queued_on=NULL
   WHERE status='Created'
     AND process_run_id IS NOT NULL
     AND event_type='ClaimSync';

  v_rows_updated := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('No of rows updated is: ' || v_rows_updated);

  UPDATE Vw_Appsession v
     SET v.Last_Change_By = NULL,
         v.Last_Change_Thru = NULL;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
        </div>
      </li>
      <li>
        <strong>Data Scenario:</strong> If an error occurs during update, the transaction will be rolled back, ensuring data consistency and auditability.
      </li>
    </ul>

    <!-- Section: Notes -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">8. Notes</h2>
    <ul style="margin-left:20px;">
      <li>Ensure proper backup before running bulk updates.</li>
      <li>Performance may be impacted for large datasets; consider batch processing.</li>
      <li>Logging and error handling are recommended for production environments.</li>
      <li>Potential enhancement: parameterize script for flexible event_type or status values.</li>
    </ul>

    <!-- Section: Summary -->
    <h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">9. Summary</h2>
    <p>
      <strong>HLP-122036_Script_v1.sql</strong> is a critical script for resetting processing fields in debit card event records. The documentation provides validation SQLs, improvement suggestions, and technical notes to support safe and effective maintenance and integration.
    </p>

  </body>
</html>
</body>
</html>