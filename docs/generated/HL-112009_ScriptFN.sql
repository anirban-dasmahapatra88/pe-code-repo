<html>
<body>
<h1>HL-112009_ScriptFN.sql</h1>
<hr/>
<ac:structured-macro ac:name="panel" ac:schema-version="1" ac:macro-id="doc-header">
  <ac:rich-text-body>
    <h1 style="color:#4A2E8E; margin-bottom:0;">Documentation: HL-112009_ScriptFN.sql</h1>
    <p style="color:#5a5a5a; margin-top:4px; font-size:14px;">
      Auto‑generated technical documentation for code review, knowledge sharing, and repository reference.
    </p>
  </ac:rich-text-body>
</ac:structured-macro>

<h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">1. Overview</h2>
<p>
  This document provides a structured explanation of the file <strong>HL-112009_ScriptFN.sql</strong>. It describes the purpose, key parameters, usage examples, dependencies, and technical notes for the SQL script.
</p>

<h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">2. Purpose</h2>
<p>
  The script updates the <strong>first_name</strong> field for specific employee records in the <strong>employee</strong> table and logs session changes in the <strong>Vw_Appsession</strong> view. It is intended for data correction or migration scenarios where employee names require updates and audit tracking is necessary.
</p>

<h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">3. Parameters / Inputs</h2>
<ul>
  <li><strong>ID</strong>: Employee identifier (numeric, primary key in <em>employee</em> table).</li>
  <li><strong>first_name</strong>: Employee's first name (string, to be updated).</li>
  <li><strong>User</strong>: System user performing the update (used in <em>Vw_Appsession</em>).</li>
</ul>

<h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">4. Example Usage</h2>
<p>Below is the original script content:</p>
<ac:code ac:language="sql">
--Tab=Before Data FN
SELECT ID, first_name FROM employee WHERE ID IN (327045, 13386174, 13403438);

Update Vw_Appsession v Set v.Last_Change_By = User, v.Last_Change_Thru = 'HLP-112009';
UPDATE employee SET first_name = 'ESTATE OF JOAN' WHERE ID = 327045;
UPDATE employee SET first_name = 'CAROLYN' WHERE ID = 13386174;
UPDATE employee SET first_name = 'BARBARA' WHERE ID = 13403438;
Update Vw_Appsession v Set v.Last_Change_By = NULL, v.Last_Change_Thru = NULL;

--Tab=After Data FN
SELECT ID, first_name FROM employee WHERE ID IN (327045, 13386174, 13403438);
</ac:code>

<h3 style="color:#4A2E8E;">Control Validation SQLs</h3>
<p><strong>Positive Scenario:</strong> Validate that updates are applied correctly.</p>
<ac:code ac:language="sql">
-- Positive Data Example
SELECT ID, first_name FROM employee WHERE ID IN (327045, 13386174, 13403438);
/* Expected Output:
ID        FIRST_NAME
327045    ESTATE OF JOAN
13386174  CAROLYN
13403438  BARBARA
*/
</ac:code>

<p><strong>Negative Scenario:</strong> Validate that no unintended records are updated.</p>
<ac:code ac:language="sql">
-- Negative Data Example
SELECT ID, first_name FROM employee WHERE ID NOT IN (327045, 13386174, 13403438) AND first_name IN ('ESTATE OF JOAN', 'CAROLYN', 'BARBARA');
/* Expected Output: No rows returned */
</ac:code>

<h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">5. Dependencies</h2>
<ul>
  <li><strong>employee</strong> table: Stores employee records.</li>
  <li><strong>Vw_Appsession</strong> view: Used for session/audit tracking.</li>
</ul>

<h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">6. Notes</h2>
<ul>
  <li>Ensure <strong>ID</strong> values exist before running updates to avoid errors.</li>
  <li>Session tracking is performed before and after updates for audit purposes.</li>
  <li>Direct updates may bypass business logic; consider using stored procedures for complex logic or logging.</li>
  <li>Performance impact is minimal due to limited row updates, but always test in non-production environments first.</li>
</ul>

<h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">7. Code Improvement Suggestions</h2>
<ul>
  <li><strong>Use a single UPDATE statement with CASE for maintainability and performance.</strong></li>
  <li><strong>Include transaction control (COMMIT/ROLLBACK) for data integrity.</strong></li>
  <li><strong>Parameterize user input to avoid hardcoding and improve auditability.</strong></li>
</ul>

<p><strong>Improved Code Example:</strong></p>
<ac:code ac:language="sql">
-- Begin transaction
BEGIN

  -- Set session audit
  UPDATE Vw_Appsession
     SET Last_Change_By = USER, Last_Change_Thru = 'HLP-112009';

  -- Update employee names using CASE
  UPDATE employee
     SET first_name = CASE
                        WHEN ID = 327045 THEN 'ESTATE OF JOAN'
                        WHEN ID = 13386174 THEN 'CAROLYN'
                        WHEN ID = 13403438 THEN 'BARBARA'
                      END
   WHERE ID IN (327045, 13386174, 13403438);

  -- Reset session audit
  UPDATE Vw_Appsession
     SET Last_Change_By = NULL, Last_Change_Thru = NULL;

  COMMIT;

END;
</ac:code>

<p><strong>Data Scenario for Improved Code:</strong></p>
<ac:code ac:language="sql">
-- Before update
SELECT ID, first_name FROM employee WHERE ID IN (327045, 13386174, 13403438);

-- Run improved script

-- After update
SELECT ID, first_name FROM employee WHERE ID IN (327045, 13386174, 13403438);
/* Expected Output:
ID        FIRST_NAME
327045    ESTATE OF JOAN
13386174  CAROLYN
13403438  BARBARA
*/
</ac:code>

<h2 style="color:#7A4CB1; border-bottom:2px solid #e2dff0; padding-bottom:6px;">8. Summary</h2>
<p>
  <strong>HL-112009_ScriptFN.sql</strong> is used for targeted employee data corrections with session tracking. The improved version enhances maintainability, auditability, and data integrity. This documentation supports efficient review, maintenance, and integration into broader workflows.
</p>
</body>
</html>