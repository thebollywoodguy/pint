DROP PROCEDURE PINTEXT.ORG_EXCEPTIONS_VALIDATIONS;

CREATE PROCEDURE PINTEXT.ORG_EXCEPTIONS_VALIDATIONS
LANGUAGE SQLSCRIPT
SQL SECURITY INVOKER
AS 
BEGIN

DECLARE v_count INTEGER;
DECLARE v_employeeid INTEGER;
DECLARE v_previouspod INTEGER;
DECLARE v_currentpod INTEGER;
DECLARE v_terminationdate INTEGER;
DECLARE v_leavestartdate INTEGER;
DECLARE v_leaveenddate INTEGER;
DECLARE v_onpaidleave INTEGER;
DECLARE v_okrpod INTEGER;
DECLARE v_localpod INTEGER;
DECLARE v_globalpod INTEGER;
DECLARE v_titlename INTEGER;
DECLARE v_podeffdate INTEGER;
DECLARE v_vceffdate INTEGER;
DECLARE v_localpodquota INTEGER;
DECLARE v_globalpodquota INTEGER;
DECLARE v_currentquota INTEGER;
DECLARE v_okrquota INTEGER;
DECLARE v_errormsg NVARCHAR(5000);
DECLARE v_valid INTEGER;
DECLARE v_intermsg INTEGER;

DECLARE CURSOR c1 FOR
SELECT * FROM org_exceptions_hold;

DELETE FROM org_exception_errors;

FOR validate_rec AS c1
DO
  
  SELECT COUNT(*) INTO v_count 
  FROM org_exceptions_hold 
  WHERE employee_id = validate_rec.employee_id;
  
  IF v_count < 2 THEN 

    -- Validate employee_id as number using IS_NUMBER function
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_employeeid := 0;
      END;
      SELECT CASE WHEN TO_NUMBER(employee_id) IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_employeeid
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate leave_end_date as date
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_leaveenddate := 0;
      END;
      SELECT CASE WHEN TO_DATE(IFNULL(leave_end_date, '01/01/2200'), 'MM/DD/YYYY') IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_leaveenddate
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate termination_Date as date
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_terminationdate := 0;
      END;
      SELECT CASE WHEN TO_DATE(IFNULL(termination_Date, '01/01/2200'), 'MM/DD/YYYY') IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_terminationdate
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate leave_start_date as date
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_leavestartdate := 0;
      END;
      SELECT CASE WHEN TO_DATE(IFNULL(leave_start_date, '01/01/2200'), 'MM/DD/YYYY') IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_leavestartdate
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate ON_PAID_LEAVE as number
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_onpaidleave := 0;
      END;
      SELECT CASE WHEN TO_NUMBER(ON_PAID_LEAVE) IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_onpaidleave
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate pod_eff_startdate as date
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_podeffdate := 0;
      END;
      SELECT CASE WHEN TO_DATE(IFNULL(pod_eff_startdate, '01/01/2200'), 'MM/DD/YYYY') IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_podeffdate
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate vc_eff_startdate as date
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_vceffdate := 0;
      END;
      SELECT CASE WHEN TO_DATE(IFNULL(vc_eff_startdate, '01/01/2200'), 'MM/DD/YYYY') IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_vceffdate
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate localpod_quota as number
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_localpodquota := 0;
      END;
      SELECT CASE WHEN TO_NUMBER(localpod_quota) IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_localpodquota
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate globalpod_quota as number
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_globalpodquota := 0;
      END;
      SELECT CASE WHEN TO_NUMBER(globalpod_quota) IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_globalpodquota
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate currentpod_quota as number
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_currentquota := 0;
      END;
      SELECT CASE WHEN TO_NUMBER(currentpod_quota) IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_currentquota
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    -- Validate okrpod_quota as number
    BEGIN
      DECLARE EXIT HANDLER FOR SQLEXCEPTION 
      BEGIN
        v_okrquota := 0;
      END;
      SELECT CASE WHEN TO_NUMBER(okrpod_quota) IS NOT NULL THEN 1 ELSE 0 END 
      INTO v_okrquota
      FROM org_exceptions_hold 
      WHERE employee_id = validate_rec.employee_id;
    END;

    IF IFNULL(TRIM(validate_rec.current_pod), '0') <> '0' THEN 

      BEGIN
        DECLARE v_pod_string NVARCHAR(5000);
        DECLARE v_pod_token NVARCHAR(500);
        DECLARE v_pos INTEGER;
        DECLARE v_found INTEGER DEFAULT 0;
        
        v_pod_string := IFNULL(TRIM(validate_rec.current_pod), 'x');
        v_currentpod := 1; -- Assume valid initially
        
        -- Loop through semicolon-separated values
        WHILE LENGTH(v_pod_string) > 0 DO
          v_pos := LOCATE(v_pod_string, ';');
          
          IF v_pos > 0 THEN
            v_pod_token := TRIM(SUBSTRING(v_pod_string, 1, v_pos - 1));
            v_pod_string := SUBSTRING(v_pod_string, v_pos + 1);
          ELSE
            v_pod_token := TRIM(v_pod_string);
            v_pod_string := '';
          END IF;
          
          -- Check if token exists in nq_podquota
          IF v_pod_token <> '' AND v_pod_token <> 'x' THEN
            SELECT COUNT(*) INTO v_found
            FROM nq_podquota n
            WHERE N.NEXTQUARTERCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSUBCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSECTOR = v_pod_token 
               OR N.NEXTQUARTERSUBSECTOR = v_pod_token 
               OR N.NEXTQUARTERMANAGERTEAM = v_pod_token 
               OR N.NEXTQUARTERTEAMNAME = v_pod_token;
            
            IF v_found = 0 THEN
              v_currentpod := 0; -- Invalid pod found
              v_pod_string := ''; -- Exit loop
            END IF;
          END IF;
        END WHILE;
      END;

    ELSE 
      v_currentpod := 2;
    END IF;

    IF IFNULL(TRIM(validate_rec.previous_pod), '0') <> '0' THEN 

      SELECT CASE WHEN IFNULL((
        SELECT IFNULL(previous_pod, '0') 
        FROM org_exceptions_hold o 
        WHERE o.employee_id = validate_rec.employee_id 
          AND EXISTS (
            SELECT 1 FROM nq_podquota n 
            WHERE N.NEXTQUARTERCHANNEL = o.current_pod 
               OR N.NEXTQUARTERSUBCHANNEL = o.current_pod 
               OR N.NEXTQUARTERSECTOR = o.current_pod 
               OR N.NEXTQUARTERSUBSECTOR = o.current_pod 
               OR N.NEXTQUARTERMANAGERTEAM = o.current_pod 
               OR N.NEXTQUARTERTEAMNAME = o.current_pod
          )
        LIMIT 1
      ), '0') <> '0' THEN 1 ELSE 0 END
      INTO v_previouspod
      FROM DUMMY;

      IF v_previouspod <> 0 THEN 
        v_previouspod := 1; 
      ELSE 
        v_previouspod := 0; 
      END IF;

    ELSE 
      v_previouspod := 2; 
    END IF;

    IF IFNULL(TRIM(validate_rec.okr_pod), '0') <> '0' THEN 

      BEGIN
        DECLARE v_pod_string NVARCHAR(5000);
        DECLARE v_pod_token NVARCHAR(500);
        DECLARE v_pos INTEGER;
        DECLARE v_found INTEGER DEFAULT 0;
        
        v_pod_string := IFNULL(TRIM(validate_rec.okr_pod), 'x');
        v_okrpod := 1; -- Assume valid initially
        
        -- Loop through semicolon-separated values
        WHILE LENGTH(v_pod_string) > 0 DO
          v_pos := LOCATE(v_pod_string, ';');
          
          IF v_pos > 0 THEN
            v_pod_token := TRIM(SUBSTRING(v_pod_string, 1, v_pos - 1));
            v_pod_string := SUBSTRING(v_pod_string, v_pos + 1);
          ELSE
            v_pod_token := TRIM(v_pod_string);
            v_pod_string := '';
          END IF;
          
          -- Check if token exists in nq_podquota
          IF v_pod_token <> '' AND v_pod_token <> 'x' THEN
            SELECT COUNT(*) INTO v_found
            FROM nq_podquota n
            WHERE N.NEXTQUARTERCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSUBCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSECTOR = v_pod_token 
               OR N.NEXTQUARTERSUBSECTOR = v_pod_token 
               OR N.NEXTQUARTERMANAGERTEAM = v_pod_token 
               OR N.NEXTQUARTERTEAMNAME = v_pod_token;
            
            IF v_found = 0 THEN
              v_okrpod := 0; -- Invalid pod found
              v_pod_string := ''; -- Exit loop
            END IF;
          END IF;
        END WHILE;
      END;

    ELSE 
      v_okrpod := 2; 
    END IF;

    IF IFNULL(TRIM(validate_rec.local_pod), '0') <> '0' THEN

      BEGIN
        DECLARE v_pod_string NVARCHAR(5000);
        DECLARE v_pod_token NVARCHAR(500);
        DECLARE v_pos INTEGER;
        DECLARE v_found INTEGER DEFAULT 0;
        
        v_pod_string := IFNULL(TRIM(validate_rec.local_pod), 'x');
        v_localpod := 1; -- Assume valid initially
        
        -- Loop through semicolon-separated values
        WHILE LENGTH(v_pod_string) > 0 DO
          v_pos := LOCATE(v_pod_string, ';');
          
          IF v_pos > 0 THEN
            v_pod_token := TRIM(SUBSTRING(v_pod_string, 1, v_pos - 1));
            v_pod_string := SUBSTRING(v_pod_string, v_pos + 1);
          ELSE
            v_pod_token := TRIM(v_pod_string);
            v_pod_string := '';
          END IF;
          
          -- Check if token exists in nq_podquota
          IF v_pod_token <> '' AND v_pod_token <> 'x' THEN
            SELECT COUNT(*) INTO v_found
            FROM nq_podquota n
            WHERE N.NEXTQUARTERCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSUBCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSECTOR = v_pod_token 
               OR N.NEXTQUARTERSUBSECTOR = v_pod_token 
               OR N.NEXTQUARTERMANAGERTEAM = v_pod_token 
               OR N.NEXTQUARTERTEAMNAME = v_pod_token;
            
            IF v_found = 0 THEN
              v_localpod := 0; -- Invalid pod found
              v_pod_string := ''; -- Exit loop
            END IF;
          END IF;
        END WHILE;
      END;

    ELSE 
      v_localpod := 2; 
    END IF;

    IF IFNULL(TRIM(validate_rec.global_pod), '0') <> '0' THEN

      BEGIN
        DECLARE v_pod_string NVARCHAR(5000);
        DECLARE v_pod_token NVARCHAR(500);
        DECLARE v_pos INTEGER;
        DECLARE v_found INTEGER DEFAULT 0;
        
        v_pod_string := IFNULL(TRIM(validate_rec.global_pod), 'x');
        v_globalpod := 1; -- Assume valid initially
        
        -- Loop through semicolon-separated values
        WHILE LENGTH(v_pod_string) > 0 DO
          v_pos := LOCATE(v_pod_string, ';');
          
          IF v_pos > 0 THEN
            v_pod_token := TRIM(SUBSTRING(v_pod_string, 1, v_pos - 1));
            v_pod_string := SUBSTRING(v_pod_string, v_pos + 1);
          ELSE
            v_pod_token := TRIM(v_pod_string);
            v_pod_string := '';
          END IF;
          
          -- Check if token exists in nq_podquota
          IF v_pod_token <> '' AND v_pod_token <> 'x' THEN
            SELECT COUNT(*) INTO v_found
            FROM nq_podquota n
            WHERE N.NEXTQUARTERCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSUBCHANNEL = v_pod_token 
               OR N.NEXTQUARTERSECTOR = v_pod_token 
               OR N.NEXTQUARTERSUBSECTOR = v_pod_token 
               OR N.NEXTQUARTERMANAGERTEAM = v_pod_token 
               OR N.NEXTQUARTERTEAMNAME = v_pod_token;
            
            IF v_found = 0 THEN
              v_globalpod := 0; -- Invalid pod found
              v_pod_string := ''; -- Exit loop
            END IF;
          END IF;
        END WHILE;
      END;

    ELSE 
      v_globalpod := 2; 
    END IF;

    IF IFNULL(TRIM(validate_rec.title_name), '0') <> '0' THEN

      SELECT CASE WHEN IFNULL((
        SELECT IFNULL(title_name, '0') 
        FROM org_exceptions_hold o 
        WHERE o.employee_id = validate_rec.employee_id 
          AND EXISTS (
            SELECT 1 FROM cs_title tl 
            WHERE tl.removedate > CURRENT_DATE 
              AND tl.name = o.title_name
          )
        LIMIT 1
      ), '0') <> '0' THEN 1 ELSE 0 END
      INTO v_intermsg
      FROM DUMMY;

      IF v_intermsg <> 0 THEN 
        v_titlename := 1; 
      ELSE 
        v_titlename := 0; 
      END IF;

    ELSE 
      v_titlename := 2; 
    END IF;

    -- Validate all fields
    SELECT 
      CASE WHEN (
        v_count <> 1 OR v_employeeid = 0 OR v_previouspod = 0 OR v_currentpod = 0 OR 
        v_terminationdate = 0 OR v_leavestartdate = 0 OR v_leaveenddate = 0 OR v_onpaidleave = 0 OR 
        v_okrpod = 0 OR v_localpod = 0 OR v_globalpod = 0 OR v_titlename = 0 OR 
        v_podeffdate = 0 OR v_vceffdate = 0 OR v_localpodquota = 0 OR v_globalpodquota = 0 OR 
        v_currentquota = 0 OR v_okrquota = 0
      ) THEN 0 ELSE 1 END
    INTO v_valid
    FROM DUMMY;

    IF v_valid = 0 THEN 

      SELECT 
        CASE WHEN v_employeeid = 0 THEN 'EmpID' ELSE '' END ||
        CASE WHEN v_previouspod = 0 THEN 'Previous Pod' ELSE '' END ||
        CASE WHEN v_currentpod = 0 THEN 'CurrentPod' ELSE '' END ||
        CASE WHEN v_terminationdate = 0 THEN 'TermDate' ELSE '' END ||
        CASE WHEN v_leavestartdate = 0 THEN 'Leavestdate' ELSE '' END ||
        CASE WHEN v_leaveenddate = 0 THEN 'LeaveEnddate' ELSE '' END ||
        CASE WHEN v_onpaidleave = 0 THEN 'paidleave' ELSE '' END ||
        CASE WHEN v_okrpod = 0 THEN 'OkrPod' ELSE '' END ||
        CASE WHEN v_localpod = 0 THEN 'LocalPod' ELSE '' END ||
        CASE WHEN v_globalpod = 0 THEN 'GlobalPod' ELSE '' END ||
        CASE WHEN v_titlename = 0 THEN 'Titlename' ELSE '' END ||
        CASE WHEN v_podeffdate = 0 THEN 'Podeffdate' ELSE '' END ||
        CASE WHEN v_vceffdate = 0 THEN 'vceffdate' ELSE '' END ||
        CASE WHEN v_localpodquota = 0 THEN 'localquota' ELSE '' END ||
        CASE WHEN v_globalpodquota = 0 THEN 'globalquota' ELSE '' END ||
        CASE WHEN v_currentquota = 0 THEN 'currentquota' ELSE '' END ||
        CASE WHEN v_okrquota = 0 THEN 'Okrquota' ELSE '' END ||
        'is invalid'
      INTO v_errormsg
      FROM DUMMY;
                            
      INSERT INTO org_exception_errors VALUES (
        validate_rec.employee_id,
        validate_rec.previous_pod,
        validate_rec.current_pod,
        validate_rec.termination_date,
        validate_rec.leave_start_Date,
        validate_rec.leave_end_date,
        validate_rec.on_paid_leave,
        validate_rec.okr_pod,
        validate_rec.local_pod,
        validate_rec.global_pod,
        validate_rec.title_name,
        validate_rec.pod_eff_startdate,
        validate_rec.vc_eff_startdate,
        validate_rec.localpod_quota,
        validate_rec.globalpod_quota,
        validate_rec.currentpod_quota,
        validate_rec.okrpod_quota,
        'Failed',
        v_errormsg
      );

    END IF;

  ELSE 

    SELECT 
      CASE WHEN v_count <> 1 THEN 'Employee repeated multiple times' ELSE '' END
    INTO v_errormsg
    FROM DUMMY;

    INSERT INTO org_exception_errors VALUES (
      validate_rec.employee_id,
      validate_rec.previous_pod,
      validate_rec.current_pod,
      validate_rec.termination_date,
      validate_rec.leave_start_Date,
      validate_rec.leave_end_date,
      validate_rec.on_paid_leave,
      validate_rec.okr_pod,
      validate_rec.local_pod,
      validate_rec.global_pod,
      validate_rec.title_name,
      validate_rec.pod_eff_startdate,
      validate_rec.vc_eff_startdate,
      validate_rec.localpod_quota,
      validate_rec.globalpod_quota,
      validate_rec.currentpod_quota,
      validate_rec.okrpod_quota,
      'Failed',
      v_errormsg
    );
                                                          
  END IF;                   

END FOR;

END;
