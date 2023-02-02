# Activite 1
SET @id := (SELECT MAX(man_id) FROM T_MANAGER_man);

SET @annee := (SELECT MIN(val) FROM (SELECT pfl_registration_date AS val FROM T_PROFILE_pfl UNION SELECT new_date AS val FROM T_NEWS_new) AS data);


# Activite 2
CREATE OR REPLACE VIEW VW_noms_prenoms
AS SELECT pfl_nom, pfl_prenom FROM t_profil_pfl;

SELECT * FROM VW_noms_prenoms;


# Activite 3
DELIMITER $$
CREATE OR REPLACE FUNCTION FN_AGE(d DATE) RETURNS int(11)
BEGIN
	DECLARE age INT DEFAULT 0;
    SET AGE = (SELECT TIMESTAMPDIFF(YEAR, d, CURDATE()));
	RETURN age;
END$$
DELIMITER ;

SELECT FN_AGE(pfl_date_naissance) FROM t_profil_pfl;


# Activite 4
DELIMITER $$
CREATE OR REPLACE PROCEDURE USP_AGE_BY_ID(IN id INT, OUT age INT)
BEGIN
	SELECT TIMESTAMPDIFF(YEAR, pfl_date_naissance, CURDATE()) INTO age FROM t_profil_pfl WHERE pfl_id = id;
END$$
DELIMITER ;

CALL USP_AGE_BY_ID(1, @age);
SELECT @age;

DELIMITER $$
CREATE OR REPLACE PROCEDURE USP_STATUT_BY_ID(IN id INT)
BEGIN
	DECLARE age INT;
	SET age = FN_AGE((SELECT pfl_date_naissance FROM t_profil_pfl WHERE pfl_id = id));
	IF age < 18 THEN
		SELECT 'mineur' AS statut;
	ELSE
		SELECT 'majeur' AS statut;
	END IF;
END$$
DELIMITER ;

CREATE OR REPLACE VIEW VW_noms_prenoms_ages
AS SELECT pfl_nom, pfl_prenom, FN_AGE(pfl_date_naissance) FROM t_profil_pfl;

DELIMITER $$
CREATE OR REPLACE PROCEDURE USP_AGE_MOYEN(OUT age INT)
BEGIN
	SELECT (sum_age/nb_pfl) INTO age FROM (SELECT SUM(FN_AGE(pfl_date_naissance)) AS sum_age, COUNT(pfl_date_naissance) AS nb_pfl FROM t_profil_pfl) AS data;
END$$
DELIMITER ;


# Activite 5
DELIMITER $$
CREATE OR REPLACE TRIGGER TR_PROFIL_BEFORE_INSERT
BEFORE INSERT ON t_profil_pfl
FOR EACH ROW
BEGIN
	SET NEW.pfl_date = CURDATE();
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE TRIGGER TR_COMPTE_AFTER_UPDATE
AFTER UPDATE ON t_compte_cpt
FOR EACH ROW
BEGIN
	UPDATE t_profil_pfl SET pfl_date = CURDATE() WHERE t_profil_pfl.pfl_id = NEW.pfl_id;
END$$
DELIMITER ;


# Suite - Activite 1
SELECT man_pseudo, pfl_last_name, pfl_first_name, new_content
	FROM T_MANAGER_man
	JOIN T_PROFILE_pfl USING(man_id)
	LEFT OUTER JOIN T_NEWS_new USING(man_id);

SELECT man_pseudo, pfl_last_name, pfl_first_name
	FROM T_MANAGER_man
	JOIN T_PROFILE_pfl USING(man_id)
	WHERE man_id NOT IN (SELECT man_id FROM T_NEWS_new);
SELECT man_pseudo, pfl_last_name, pfl_first_name
	FROM T_MANAGER_man
	JOIN T_PROFILE_pfl USING(man_id)
	LEFT OUTER JOIN T_NEWS_new USING(man_id)
    WHERE new_content IS NULL;


# Suite - Activite 2
DELIMITER $$
CREATE OR REPLACE FUNCTION FN_PLAYERS_FROM_MATCH_ID(id INT UNSIGNED) RETURNS TEXT
BEGIN
	RETURN (SELECT GROUP_CONCAT(player_pseudo) FROM T_PLAYER_player WHERE match_id = id);
END$$
DELIMITER ;

SELECT FN_PLAYERS_FROM_MATCH_ID(1);

DELIMITER $$
CREATE OR REPLACE PROCEDURE USP_END_MATCH(IN id INT UNSIGNED)
BEGIN
	DECLARE title VARCHAR(200);
	DECLARE start_date DATE;
	DECLARE end_date DATE;

	SELECT match_title, match_start_date, match_end_date INTO title, start_date, end_date FROM T_MATCH_match WHERE match_id = id;
    
    IF end_date IS NOT NULL THEN
        INSERT INTO T_NEWS_new(new_title, new_content, new_date, man_id) VALUES
        (
            CONCAT('Le match "', title, '" viens de se terminer !'),
            CONCAT('Merci à tous les participant qui y ont participé du ', start_date, ' au ', end_date, ' !\n\nListe des participants:\n', FN_PLAYERS_FROM_MATCH_ID(id)),
            end_date,
            1
        );
	END IF;
END$$
DELIMITER ;

CALL USP_END_MATCH(7);

DELIMITER $$
CREATE OR REPLACE TRIGGER TR_MATCH_AFTER_UPDATE
AFTER UPDATE ON T_MATCH_match
FOR EACH ROW
BEGIN
	IF OLD.match_end_date IS NULL && NEW.match_end_date IS NOT NULL THEN
		CALL USP_END_MATCH(NEW.match_id);
	END IF;
END$$
DELIMITER ;

UPDATE T_MATCH_match SET match_enabled = 0 WHERE match_id = 7;


# Suite - Activite 3
DELIMITER $$
CREATE OR REPLACE PROCEDURE USP_MATCH_INFO(OUT nb_ended INT, OUT nb_ongoing INT, OUT nb_coming INT)
BEGIN
	DECLARE curdate DATE;
	SET curdate = CURDATE();

	SELECT
    	COUNT(CASE WHEN match_end_date IS NOT NULL && match_end_date <= curdate THEN 1 END),
    	COUNT(CASE WHEN match_start_date IS NOT NULL && match_start_date <= curdate && match_end_date IS NULL THEN 1 END),
        COUNT(CASE WHEN match_start_date IS NULL || match_start_date > curdate THEN 1 END)
        INTO nb_ended, nb_ongoing, nb_coming
        FROM T_MATCH_match;
END$$
DELIMITER ;

CALL USP_MATCH_INFO(@nb_ended, @nb_ongoing, @nb_coming);
SELECT @nb_ended, @nb_ongoing, @nb_coming;


# Suite - Activite 5
###################### VIEWS #######################
CREATE OR REPLACE VIEW VW_Accounts AS
SELECT * FROM T_PROFILE_pfl
JOIN T_MANAGER_man USING(man_id);

CREATE OR REPLACE VIEW VW_Questions_Answers AS
SELECT * FROM T_QUESTION_qst
JOIN T_ANSWER_ans USING(qst_id);

CREATE OR REPLACE VIEW VW_Last_News AS
SELECT * FROM T_NEWS_new
ORDER BY new_id DESC
LIMIT 1;

DELIMITER $$
#################### FUNCTIONS #####################
CREATE OR REPLACE FUNCTION FN_HASH_PW(pw TEXT)
RETURNS CHAR(128)
BEGIN
	RETURN SHA2(CONCAT(pw, 'sPrCHtXU75e@Fu&wKjvy31&vfz77oJ'), 512);
END$$

CREATE OR REPLACE FUNCTION FN_VALID_LOGIN(pseudo VARCHAR(20), password TEXT)
RETURNS TINYINT UNSIGNED
BEGIN
	DECLARE hashed_pw CHAR(128);
	SET hashed_pw = FN_HASH_PW(password);

	RETURN (
		SELECT (COUNT(*) > 0)
		FROM T_MANAGER_man
		JOIN T_PROFILE_pfl USING(man_id)
		WHERE man_pseudo = pseudo && man_pw = hashed_pw && pfl_active = 1
	);
END$$

CREATE OR REPLACE FUNCTION FN_QUESTION_VALID_ANSWERS(_qst_id INT UNSIGNED)
RETURNS INT UNSIGNED
BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM T_ANSWER_ans
		WHERE ans_valid = 1 && qst_id = _qst_id
	);
END$$

CREATE OR REPLACE FUNCTION FN_MATCH_AVERAGE_SCORE(_match_id INT UNSIGNED)
RETURNS FLOAT
BEGIN
	RETURN (
		SELECT AVG(player_score)
		FROM T_PLAYER_player
		WHERE match_id = _match_id;
	);
END$$

#################### PROCEDURES ####################
CREATE OR REPLACE PROCEDURE USP_new_account(
	IN first_name VARCHAR(80),
	IN last_name VARCHAR(80),
	IN role CHAR(1),
	IN active TINYINT(1),
	IN pseudo VARCHAR(20),
	IN password TEXT
)
BEGIN
	INSERT INTO T_MANAGER_man(man_pseudo, man_pw) VALUES
		(pseudo, password);

	INSERT INTO T_PROFILE_pfl(pfl_first_name, pfl_last_name, pfl_role, pfl_registration_date, pfl_active,  man_id) VALUES
	(
		first_name,
		last_name,
		role,
		CURDATE(),
		active,
		SCOPE_IDENTITY()
	);
END$$

CREATE OR REPLACE PROCEDURE USP_quiz_enable(IN id INT UNSIGNED, IN bool TINYINT(1))
BEGIN
	UPDATE T_QUIZ_quiz SET quiz_enabled = bool WHERE quiz_id = id;
END$$

CREATE OR REPLACE PROCEDURE USP_question_reorder(IN id INT UNSIGNED, IN new_order TINYINT UNSIGNED)
BEGIN
	DECLARE _quiz_id INT UNSIGNED;

	SELECT quiz_id INTO _quiz_id FROM T_QUESTION_qst WHERE qst_id = id;

	UPDATE T_QUESTION_qst
	SET qst_order = (
		CASE
			WHEN qst_id = id THEN new_order
			WHEN qst_id != id && qst_order >= new_order THEN qst_order + 1
		END)
	WHERE quiz_id = _quiz_id;
END$$

CREATE OR REPLACE PROCEDURE USP_question_enable(IN id INT UNSIGNED, IN bool TINYINT(1))
BEGIN
	UPDATE T_QUESTION_qst SET qst_enabled = bool WHERE qst_id = id;
END$$

CREATE OR REPLACE PROCEDURE USP_match_enable(IN id INT UNSIGNED, IN bool TINYINT(1))
BEGIN
	UPDATE T_MATCH_match SET match_enabled = bool WHERE match_id = id;
END$$

############# TRIGGERS	BEFORE	INSERT #############
CREATE OR REPLACE TRIGGER TR_MANAGER_BEFORE_INSERT BEFORE INSERT ON T_MANAGER_man FOR EACH ROW
BEGIN
	SET NEW.man_pw = FN_HASH_PW(NEW.man_pw);
END$$

CREATE OR REPLACE TRIGGER TR_PROFILE_BEFORE_INSERT BEFORE INSERT ON T_PROFILE_pfl FOR EACH ROW
BEGIN
	SET NEW.pfl_registration_date = CURDATE();
END$$

############# TRIGGERS	BEFORE	UPDATE #############
CREATE OR REPLACE TRIGGER TR_MANAGER_BEFORE_UPDATE BEFORE UPDATE ON T_MANAGER_man FOR EACH ROW
BEGIN
	IF OLD.man_pw != NEW.man_pw THEN
		DECLARE hashed_pw CHAR(128);
		SET hashed_pw = FN_HASH_PW(NEW.man_pw);

		IF OLD.man_pw != hashed_pw THEN
			SET NEW.man_pw = hashed_pw;
		END IF;
	END IF;
END$$

############# TRIGGERS	AFTER	UPDATE #############
CREATE OR REPLACE TRIGGER TR_ANSWER_AFTER_UPDATE AFTER UPDATE ON T_ANSWER_ans FOR EACH ROW
BEGIN
	IF FN_QUESTION_VALID_ANSWERS(NEW.qst_id) = 0 THEN
		UPDATE T_QUESTION_qst SET qst_enabled = 0 WHERE qst_id = NEW.qst_id;
	END IF;
END$$

############# TRIGGERS	BEFORE	DELETE #############
CREATE OR REPLACE TRIGGER TR_MANAGER_BEFORE_DELETE BEFORE DELETE ON T_MANAGER_man FOR EACH ROW
BEGIN
	DELETE FROM T_NEWS_new WHERE man_id = OLD.man_id;
	UPDATE T_QUIZ_quiz SET man_id = 1 WHERE man_id = OLD.man_id;
	UPDATE T_MATCH_match SET man_id = 1 WHERE man_id = OLD.man_id;
END$$

CREATE OR REPLACE TRIGGER TR_QUIZ_BEFORE_DELETE BEFORE DELETE ON T_QUIZ_quiz FOR EACH ROW
BEGIN
	DELETE FROM T_QUESTION_qst WHERE quiz_id = OLD.quiz_id;
END$$

CREATE OR REPLACE TRIGGER TR_QUESTION_BEFORE_DELETE BEFORE DELETE ON T_QUESTION_qst FOR EACH ROW
BEGIN
	DELETE FROM T_ANSWER_ans WHERE qst_id = OLD.qst_id;
END$$

CREATE OR REPLACE TRIGGER TR_MATCH_BEFORE_DELETE BEFORE DELETE ON T_MATCH_match FOR EACH ROW
BEGIN
	DELETE FROM T_PLAYER_player WHERE match_id = OLD.match_id;
END$$

############# TRIGGERS	AFTER	DELETE #############
CREATE OR REPLACE TRIGGER TR_ANSWER_AFTER_DELETE AFTER DELETE ON T_ANSWER_ans FOR EACH ROW
BEGIN
	IF (SELECT COUNT(*) FROM T_QUESTION_qst WHERE qst_id = OLD.qst_id) = 1 || FN_QUESTION_VALID_ANSWERS(OLD.qst_id) = 0 THEN
		UPDATE T_QUESTION_qst SET qst_enabled = 0 WHERE qst_id = OLD.qst_id;
	END IF;
END$$
DELIMITER ;


# Suite - Activite 5
DELIMITER $$
CREATE OR REPLACE TRIGGER TR_QUESTION_BEFORE_DELETE
BEFORE DELETE ON T_QUESTION_qst
FOR EACH ROW
BEGIN
	DELETE FROM T_ANSWER_ans WHERE qst_id = OLD.qst_id;
END$$

CREATE OR REPLACE TRIGGER TR_QUESTION_AFTER_DELETE
AFTER DELETE ON T_QUESTION_qst
FOR EACH ROW
BEGIN
	DECLARE title TEXT;
	DECLARE nb_qst_remaining INT UNSIGNED;
	DECLARE nb_matches_related INT UNSIGNED;
	DECLARE matches_related TEXT;
	DECLARE nb_man_concerned INT UNSIGNED;
	DECLARE man_concerned TEXT;


	SET title = CONCAT('Modification du quiz ', OLD.quiz_id);
	SELECT COUNT(*) INTO nb_qst_remaining FROM T_QUESTION_qst WHERE quiz_id = OLD.quiz_id;
	SELECT
		COUNT(match_id),
		GROUP_CONCAT(match_id),
		COUNT(DISTINCT man_id),
		GROUP_CONCAT(DISTINCT man_pseudo)
		INTO nb_matches_related, matches_related, nb_man_concerned, man_concerned
		FROM T_MATCH_match
		JOIN T_MANAGER_man USING(man_id)
		WHERE quiz_id = OLD.quiz_id;

	DELETE FROM T_NEWS_new WHERE new_title = title;
	INSERT INTO T_NEWS_new(new_title, new_content, new_date, man_id) VALUES
    (
        title,
        CONCAT(
        	CASE
        		WHEN nb_qst_remaining > 1 THEN CONCAT('Suppression d\'une question, ', nb_qst_remaining, ' restantes.')
        		WHEN nb_qst_remaining = 1 THEN 'ATTENTION, plus qu’une question !'
        		ELSE 'QUIZ VIDE !'
        	END,
        	'\n\n',
        	CASE
        		WHEN nb_matches_related > 1 THEN CONCAT(
        				'Matchs associés: ', matches_related, '\n',
        				CASE
        					WHEN nb_man_concerned > 1 THEN CONCAT('Formateurs concernés: ', man_concerned)
        					ELSE CONCAT('Formateur concerné: ', man_concerned)
        				END
        			)
        		WHEN nb_matches_related = 1 THEN CONCAT(
        				'Match associé: ', matches_related, '\n',
        				CASE
        					WHEN nb_man_concerned > 1 THEN CONCAT('Formateurs concernés: ', man_concerned)
        					ELSE CONCAT('Formateur concerné: ', man_concerned)
        				END
        			)
        		ELSE 'Aucun match associé à ce quiz pour l’instant !'
        	END
        ),
        CURDATE(),
        1
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE OR REPLACE TRIGGER TR_MATCH_AFTER_UPDATE
AFTER UPDATE ON T_MATCH_match
FOR EACH ROW
BEGIN
	IF OLD.match_start_date IS NOT NULL && (NEW.match_start_date IS NULL || NEW.match_start_date >= CURDATE()) &&
		OLD.match_end_date IS NOT NULL && NEW.match_end_date IS NULL
	THEN
		DELETE FROM T_PLAYER_player WHERE match_id = NEW.match_id;
	END IF;
END$$
DELIMITER ;