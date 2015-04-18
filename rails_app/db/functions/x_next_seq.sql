-- Function: x_next_seq(character varying, date, character varying)

-- DROP FUNCTION x_next_seq(character varying, date, character varying);

CREATE OR REPLACE FUNCTION x_next_seq(
    IN p_type character varying,
    IN p_date date,
    IN p_mode character varying,
    OUT next_no integer)
  RETURNS integer AS
$BODY$
    DECLARE temp_last_no INTEGER;
    DECLARE temp_first_date CHAR(10);
    DECLARE temp_month_no CHAR(2);
    DECLARE temp_date_no CHAR(2);
    DECLARE loop_count INTEGER;
    DECLARE max_loop INTEGER;
    DECLARE str_last_number CHAR(2);
    DECLARE time_out CONSTANT INTEGER DEFAULT 60;               -- set timeout here, in unit of second
    DECLARE poll_time CONSTANT DOUBLE PRECISION DEFAULT 0.2;    -- set poll time here, in unit of second

    DECLARE temp_id INTEGER;    -- RWC
BEGIN
    loop_count := 0;
    max_loop := cast(time_out as double precision) / poll_time;

    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;

    IF p_mode in ('DAILY') THEN
        -- REFORMAT date = 'YYYY-mm-dd'
        --  number is initialized daily and start date is generated date
        --  raise notice 'type % group initial daily, start gen date', p_type;

        WHILE loop_count < max_loop LOOP
            BEGIN
                --  select last_number to temp_last_no
                SELECT last_number
                    INTO temp_last_no
                    FROM sys_seqs
                    WHERE seq_type = p_type AND seq_date = p_date
                    FOR UPDATE NOWAIT;

                loop_count := max_loop;
                IF temp_last_no IS NULL THEN

                    -- RWC Add
                    SELECT id into temp_id FROM sys_dummies order by id limit 1 FOR UPDATE NOWAIT;
                    
                    temp_date_no := cast(extract(DAY from p_date) as varchar);
                    IF length(temp_date_no) = 1 THEN
                        temp_date_no := '0' || temp_date_no;
                    END IF;
                    temp_month_no := cast(extract(MONTH from p_date) as varchar);
                    IF NOT (temp_month_no in ('10','11','12')) THEN
                        temp_month_no := '0' || temp_month_no;
                    END IF;
                    -- temp_first_date := temp_date_no || '/' || temp_month_no || '/' || cast(extract(YEAR from p_date) as varchar);
                    temp_first_date := cast(extract(YEAR from p_date) as varchar) || '-' || temp_month_no || '-' || temp_date_no ;

                    INSERT INTO sys_seqs(seq_type, seq_date, last_number, created_at, updated_at) VALUES (p_type, cast(temp_first_date as date), 1, now(), now());

                    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;
                    next_no := 1;
                    RETURN;
                ELSE
                    temp_last_no := temp_last_no + 1;

                    UPDATE sys_seqs SET last_number = temp_last_no, updated_at = now()
                        WHERE seq_type = p_type AND seq_date = p_date;

                    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;
                    next_no := temp_last_no;
                    RETURN;
                END IF;
            EXCEPTION
                WHEN lock_not_available THEN
                    BEGIN
                        perform pg_sleep(poll_time);
                        loop_count := loop_count + 1;
                    END;
                WHEN OTHERS THEN
                    BEGIN
                        RAISE EXCEPTION '%', sqlerrm;
                        next_no := NULL;
                        RETURN;
                    END;
            END;
        END LOOP;
        next_no := NULL;
        RETURN;

    ELSIF p_mode in ('MONTHLY') THEN
        -- REFORMAT date = 'YYYY-mm-dd'
        --  number is initialized monthly and start date is '1/<mm>/<yyyy>'
        --  raise notice 'type % group initial monthly, start 1/m/y', p_type;

        WHILE loop_count < max_loop LOOP
            BEGIN

                SELECT last_number
                    INTO temp_last_no
                    FROM sys_seqs
                    WHERE seq_type = p_type AND extract(MONTH from seq_date) = extract(MONTH from p_date) AND
                    extract(YEAR from seq_date) = extract(YEAR from p_date)
                    FOR UPDATE NOWAIT;

                loop_count := max_loop;
                IF temp_last_no IS NULL THEN
                
                    -- RWC Add
                    SELECT id into temp_id FROM sys_dummies order by id limit 1 FOR UPDATE NOWAIT;

                    temp_month_no := cast(extract(MONTH from p_date) as varchar);
                    IF NOT (temp_month_no in ('10','11','12')) THEN
                        temp_month_no := '0' || temp_month_no;
                    END IF;
                    -- temp_first_date := '01/' || temp_month_no || '/' || CAST(extract(YEAR from p_date) as varchar);
                    temp_date_no = '01';
                    temp_first_date := cast(extract(YEAR from p_date) as varchar) || '-' || temp_month_no || '-' || temp_date_no ;

                    INSERT INTO sys_seqs(seq_type, seq_date, last_number, created_at, updated_at) VALUES (p_type, cast(temp_first_date as date), 1, now(), now());

                    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;
                    next_no := 1;
                    RETURN;
                ELSE
                    temp_last_no := temp_last_no + 1;

                    UPDATE sys_seqs SET last_number = temp_last_no, updated_at = now()
                        WHERE seq_type = p_type AND extract(MONTH from seq_date) = extract(MONTH from p_date) AND
                        extract(YEAR from seq_date) = extract(YEAR from p_date);

                    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;
                    next_no := temp_last_no;
                    RETURN;
                END IF;
            EXCEPTION
                WHEN lock_not_available THEN
                    BEGIN
                        perform pg_sleep(poll_time);
                        loop_count := loop_count + 1;
                    END;
                WHEN OTHERS THEN
                    BEGIN
                        RAISE EXCEPTION '%', sqlerrm;
                        next_no := NULL;
                        RETURN;
                    END;
            END;
        END LOOP;
        next_no := NULL;
        RETURN;

    ELSIF p_mode in ('YEARLY') THEN
        -- REFORMAT date = 'YYYY-mm-dd'
        --  number is initialized yearly
        --  raise notice 'type % group initial yearly, start 1/1/y', p_type;

        WHILE loop_count < max_loop LOOP
            BEGIN

                SELECT last_number
                    INTO temp_last_no
                    FROM sys_seqs
                    WHERE seq_type = p_type AND extract(YEAR from seq_date) = extract(YEAR from p_date)
                    FOR UPDATE NOWAIT;

                loop_count := max_loop;
                IF temp_last_no IS NULL THEN

                    -- RWC Add
                    SELECT id into temp_id FROM sys_dummies order by id limit 1 FOR UPDATE NOWAIT;

                
                    -- temp_first_date := '01/01/' || cast(extract(YEAR from p_date) as varchar);
                    temp_date_no = '01';
                    temp_month_no = '01';
                    temp_first_date := cast(extract(YEAR from p_date) as varchar) || '-' || temp_month_no || '-' || temp_date_no ;

                    INSERT INTO sys_seqs(seq_type, seq_date, last_number, created_at, updated_at) VALUES (p_type, cast(temp_first_date as date), 1, now(), now());

                    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;
                    next_no := 1;
                    RETURN;
                ELSE
                    temp_last_no := temp_last_no + 1;

                    UPDATE sys_seqs SET last_number = temp_last_no, updated_at = now()
                        WHERE seq_type = p_type AND extract(YEAR from seq_date) = extract(YEAR from p_date);

                    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;
                    next_no := temp_last_no;
                    RETURN;
                END IF;
            EXCEPTION
                WHEN lock_not_available THEN
                    BEGIN
                        perform pg_sleep(poll_time);
                        loop_count := loop_count + 1;
                    END;
                WHEN OTHERS THEN
                    BEGIN
                        RAISE EXCEPTION '%', sqlerrm;
                        next_no := NULL;
                        RETURN;
                    END;
            END;
        END LOOP;
        next_no := NULL;
        RETURN;

    ELSE
        -- REFORMAT date = 'YYYY-mm-dd'
        --  number is initialized once and start date as '1/1/<yyyy> (but no meaning)' -- 1/1/1970
        --  raise notice 'type % group initial once, start 1/1/y', p_type;
        WHILE loop_count < max_loop LOOP
            BEGIN

                SELECT last_number
                    INTO temp_last_no
                    FROM sys_seqs
                    WHERE seq_type = p_type
                    FOR UPDATE NOWAIT;

                loop_count := max_loop;
                IF temp_last_no IS NULL THEN

                    -- RWC Add
                    SELECT id into temp_id FROM sys_dummies order by id limit 1 FOR UPDATE NOWAIT;
                
                    -- temp_first_date := '01/01/' || cast( extract(YEAR from p_date) as varchar);
                    temp_date_no = '01';
                    temp_month_no = '01';
                    temp_first_date := cast(extract(YEAR from p_date) as varchar) || '-' || temp_month_no || '-' || temp_date_no ;

                    next_no := 1;

                    INSERT INTO sys_seqs(seq_type, seq_date, last_number, created_at, updated_at) VALUES (p_type, cast(temp_first_date as date), next_no, now(), now());

                    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;
                    RETURN;
                ELSE

                    temp_last_no := temp_last_no + 1;

                    UPDATE sys_seqs SET last_number = temp_last_no, updated_at = now()
                        WHERE seq_type = p_type;

                    SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL READ COMMITTED; SET SESSION STATEMENT_TIMEOUT = DEFAULT;
                    next_no := temp_last_no;
                    RETURN;
                END IF;
            EXCEPTION
                WHEN lock_not_available THEN
                    BEGIN
                        perform pg_sleep(poll_time);
                        loop_count := loop_count + 1;
                    END;
                WHEN OTHERS THEN
                    BEGIN
                        RAISE EXCEPTION '%', sqlerrm;
                        next_no := NULL;
                        RETURN;
                    END;
            END;
        END LOOP;
        next_no := NULL;
        RETURN;

    END IF;
    RETURN;

END $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
--ALTER FUNCTION x_next_seq(character varying, date, character varying)
--  OWNER TO vipshipping;
