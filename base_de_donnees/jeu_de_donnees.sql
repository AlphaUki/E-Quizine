DELIMITER $$

#################### FUNCTIONS #####################
CREATE OR REPLACE FUNCTION FN_HASH_PW(pw TEXT)
RETURNS CHAR(128) CHARSET ascii
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
	DECLARE average_score FLOAT;
    
    SELECT AVG(player_score) INTO average_score
	FROM T_PLAYER_player
	WHERE match_id = _match_id;

	RETURN average_score;
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
	SET NEW.man_pw := FN_HASH_PW(NEW.man_pw);
END$$

CREATE OR REPLACE TRIGGER TR_PROFILE_BEFORE_INSERT BEFORE INSERT ON T_PROFILE_pfl FOR EACH ROW
BEGIN
	SET NEW.pfl_registration_date := CURDATE();
END$$

CREATE OR REPLACE TRIGGER TR_NEWS_BEFORE_INSERT BEFORE INSERT ON T_NEWS_new FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_QUIZ_BEFORE_INSERT BEFORE INSERT ON T_QUIZ_quiz FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_QUESTION_BEFORE_INSERT BEFORE INSERT ON T_QUESTION_qst FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_ANSWER_BEFORE_INSERT BEFORE INSERT ON T_ANSWER_ans FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_MATCH_BEFORE_INSERT BEFORE INSERT ON T_MATCH_match FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_PLAYER_BEFORE_INSERT BEFORE INSERT ON T_PLAYER_player FOR EACH ROW BEGIN END$$

############# TRIGGERS	AFTER	INSERT #############
CREATE OR REPLACE TRIGGER TR_MANAGER_AFTER_INSERT AFTER INSERT ON T_MANAGER_man FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_PROFILE_AFTER_INSERT AFTER INSERT ON T_PROFILE_pfl FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_NEWS_AFTER_INSERT AFTER INSERT ON T_NEWS_new FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_QUIZ_AFTER_INSERT AFTER INSERT ON T_QUIZ_quiz FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_QUESTION_AFTER_INSERT AFTER INSERT ON T_QUESTION_qst FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_ANSWER_AFTER_INSERT AFTER INSERT ON T_ANSWER_ans FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_MATCH_AFTER_INSERT AFTER INSERT ON T_MATCH_match FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_PLAYER_AFTER_INSERT AFTER INSERT ON T_PLAYER_player FOR EACH ROW BEGIN END$$

############# TRIGGERS	BEFORE	UPDATE #############
CREATE OR REPLACE TRIGGER TR_MANAGER_BEFORE_UPDATE BEFORE UPDATE ON T_MANAGER_man FOR EACH ROW
BEGIN
	/*
	DECLARE hashed_pw CHAR(128);

	IF OLD.man_pw != NEW.man_pw THEN
		SET hashed_pw = FN_HASH_PW(NEW.man_pw);

		IF OLD.man_pw != hashed_pw THEN
			SET NEW.man_pw = hashed_pw;
		END IF;
	END IF;
	*/
END$$

CREATE OR REPLACE TRIGGER TR_PROFILE_BEFORE_UPDATE BEFORE UPDATE ON T_PROFILE_pfl FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_NEWS_BEFORE_UPDATE BEFORE UPDATE ON T_NEWS_new FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_QUIZ_BEFORE_UPDATE BEFORE UPDATE ON T_QUIZ_quiz FOR EACH ROW BEGIN END$$

CREATE OR REPLACE TRIGGER TR_QUESTION_BEFORE_UPDATE BEFORE UPDATE ON T_QUESTION_qst FOR EACH ROW
BEGIN
	#IF OLD.qst_order != NEW.qst_order && (SELECT COUNT(*) FROM T_QUESTION_qst WHERE qst_order = NEW.qst_order) > 0 THEN
	#	UPDATE T_QUESTION_qst
	#	SET qst_order = qst_order + 1
	#	WHERE qst_order >= NEW.qst_order;
	#END IF;
END$$

CREATE OR REPLACE TRIGGER TR_ANSWER_BEFORE_UPDATE BEFORE UPDATE ON T_ANSWER_ans FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_MATCH_BEFORE_UPDATE BEFORE UPDATE ON T_MATCH_match FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_PLAYER_BEFORE_UPDATE BEFORE UPDATE ON T_PLAYER_player FOR EACH ROW BEGIN END$$

############# TRIGGERS	AFTER	UPDATE #############
CREATE OR REPLACE TRIGGER TR_MANAGER_AFTER_UPDATE AFTER UPDATE ON T_MANAGER_man FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_PROFILE_AFTER_UPDATE AFTER UPDATE ON T_PROFILE_pfl FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_NEWS_AFTER_UPDATE AFTER UPDATE ON T_NEWS_new FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_QUIZ_AFTER_UPDATE AFTER UPDATE ON T_QUIZ_quiz FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_QUESTION_AFTER_UPDATE AFTER UPDATE ON T_QUESTION_qst FOR EACH ROW BEGIN END$$

CREATE OR REPLACE TRIGGER TR_ANSWER_AFTER_UPDATE AFTER UPDATE ON T_ANSWER_ans FOR EACH ROW
BEGIN
	IF FN_QUESTION_VALID_ANSWERS(NEW.qst_id) = 0 THEN
		UPDATE T_QUESTION_qst SET qst_enabled = 0 WHERE qst_id = NEW.qst_id;
	END IF;
END$$

CREATE OR REPLACE TRIGGER TR_MATCH_AFTER_UPDATE AFTER UPDATE ON T_MATCH_match FOR EACH ROW BEGIN
	IF ((OLD.match_start_date IS NOT NULL && NEW.match_start_date IS NULL) || NEW.match_start_date >= CURDATE()) && NEW.match_end_date IS NULL
	THEN
		DELETE FROM T_PLAYER_player WHERE match_id = NEW.match_id;
	END IF;
END$$

CREATE OR REPLACE TRIGGER TR_PLAYER_AFTER_UPDATE AFTER UPDATE ON T_PLAYER_player FOR EACH ROW BEGIN END$$

############# TRIGGERS	BEFORE	DELETE #############
CREATE OR REPLACE TRIGGER TR_MANAGER_BEFORE_DELETE BEFORE DELETE ON T_MANAGER_man FOR EACH ROW
BEGIN
	DELETE FROM T_NEWS_new WHERE man_id = OLD.man_id;
	UPDATE T_QUIZ_quiz SET man_id = 1 WHERE man_id = OLD.man_id;
	UPDATE T_MATCH_match SET man_id = 1 WHERE man_id = OLD.man_id;
END$$

CREATE OR REPLACE TRIGGER TR_PROFILE_BEFORE_DELETE BEFORE DELETE ON T_PROFILE_pfl FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_NEWS_BEFORE_DELETE BEFORE DELETE ON T_NEWS_new FOR EACH ROW BEGIN END$$

CREATE OR REPLACE TRIGGER TR_QUIZ_BEFORE_DELETE BEFORE DELETE ON T_QUIZ_quiz FOR EACH ROW
BEGIN
	DELETE FROM T_QUESTION_qst WHERE quiz_id = OLD.quiz_id;
END$$

CREATE OR REPLACE TRIGGER TR_QUESTION_BEFORE_DELETE BEFORE DELETE ON T_QUESTION_qst FOR EACH ROW
BEGIN
	DELETE FROM T_ANSWER_ans WHERE qst_id = OLD.qst_id;
END$$

CREATE OR REPLACE TRIGGER TR_ANSWER_BEFORE_DELETE BEFORE DELETE ON T_ANSWER_ans FOR EACH ROW BEGIN END$$

CREATE OR REPLACE TRIGGER TR_MATCH_BEFORE_DELETE BEFORE DELETE ON T_MATCH_match FOR EACH ROW
BEGIN
	DELETE FROM T_PLAYER_player WHERE match_id = OLD.match_id;
END$$

CREATE OR REPLACE TRIGGER TR_PLAYER_BEFORE_DELETE BEFORE DELETE ON T_PLAYER_player FOR EACH ROW BEGIN END$$

############# TRIGGERS	AFTER	DELETE #############
CREATE OR REPLACE TRIGGER TR_MANAGER_AFTER_DELETE AFTER DELETE ON T_MANAGER_man FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_PROFILE_AFTER_DELETE AFTER DELETE ON T_PROFILE_pfl FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_NEWS_AFTER_DELETE AFTER DELETE ON T_NEWS_new FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_QUIZ_AFTER_DELETE AFTER DELETE ON T_QUIZ_quiz FOR EACH ROW BEGIN END$$

CREATE OR REPLACE TRIGGER TR_QUESTION_AFTER_DELETE AFTER DELETE ON T_QUESTION_qst FOR EACH ROW BEGIN
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
        		WHEN nb_qst_remaining > 1 THEN CONCAT('Suppression d''une question, ', nb_qst_remaining, ' restantes.')
        		WHEN nb_qst_remaining = 1 THEN 'ATTENTION, plus qu???une question !'
        		ELSE 'QUIZ VIDE !'
        	END,
        	'\n\n',
        	CASE
        		WHEN nb_matches_related > 1 THEN CONCAT(
        				'Matchs associ??s: ', matches_related, '\n',
        				CASE
        					WHEN nb_man_concerned > 1 THEN CONCAT('Formateurs concern??s: ', man_concerned)
        					ELSE CONCAT('Formateur concern??: ', man_concerned)
        				END
        			)
        		WHEN nb_matches_related = 1 THEN CONCAT(
        				'Match associ??: ', matches_related, '\n',
        				CASE
        					WHEN nb_man_concerned > 1 THEN CONCAT('Formateurs concern??s: ', man_concerned)
        					ELSE CONCAT('Formateur concern??: ', man_concerned)
        				END
        			)
        		ELSE 'Aucun match associ?? ?? ce quiz pour l???instant !'
        	END
        ),
        CURDATE(),
        1
    );
END$$

CREATE OR REPLACE TRIGGER TR_ANSWER_AFTER_DELETE AFTER DELETE ON T_ANSWER_ans FOR EACH ROW
BEGIN
	IF (SELECT COUNT(*) FROM T_QUESTION_qst WHERE qst_id = OLD.qst_id) = 1 || FN_QUESTION_VALID_ANSWERS(OLD.qst_id) = 0 THEN
		UPDATE T_QUESTION_qst SET qst_enabled = 0 WHERE qst_id = OLD.qst_id;
	END IF;
END$$

CREATE OR REPLACE TRIGGER TR_MATCH_AFTER_DELETE AFTER DELETE ON T_MATCH_match FOR EACH ROW BEGIN END$$
CREATE OR REPLACE TRIGGER TR_PLAYER_AFTER_DELETE AFTER DELETE ON T_PLAYER_player FOR EACH ROW BEGIN END$$

DELIMITER ;


INSERT INTO T_MANAGER_man(man_id, man_pseudo, man_pw) VALUES
	(1, 'responsable', 'resp22_ZUIQ'),
	(2, 'nlbeaz', 'yeet'),
	(3, 'thomandjerry', 'thom'),
	(5, 'clairance', 'clair'),
	(6, 'mengot', 'meng'),
	(7, 'bonnobo', 'C43a$3fK1AY7T@4cD!y5ivUnHAJ#!B'),
	(8, 'matracus', '#G&u$8dRz1699Wa#PdLnS14Dv^lYvj'),
	(9, 'karmaine', 'TZTz6GzEaKSY9hR9s5bI34r*t9@EEA');

INSERT INTO T_PROFILE_pfl(pfl_first_name, pfl_last_name, pfl_role, pfl_registration_date, pfl_active,  man_id) VALUES
	('Val??rie', 'Marc', 'A', '2022-09-11', 1, 1),
	('Nicolas', 'Le Bars', 'A', '2022-09-11', 1, 2),
	('Jeremiah', 'Thompson', 'F', '2022-09-20', 1, 3),
	('Marc', 'Leclercq', 'F', '2022-10-05', 0, 5),
	('Margot', 'Mendes', 'F', '2022-10-07', 1, 6),
	('Agn??s', 'Bonneau', 'F', '2022-10-08', 1, 7),
	('Marius', 'Brebion', 'F', '2022-10-10', 1, 8),
	('Elsa', 'Gautier', 'F', '2022-10-11', 1, 9);

INSERT INTO T_NEWS_new(new_title, new_content, new_date, man_id) VALUES
	('Le match "Les pros de l\'agriculture" viens de se terminer !', 'Merci ?? tous les participant qui y ont particip?? du 2022-09-22 au 2022-09-22 !<br/><br/>Liste des participants:<br/>Andr??e N., Marcelle G., Ren?? d., Virginie B., Jeanne R., Claudine A., R??my R., Marie C., Jacques T., Jules B., Colette W., Raymond B., No??mi F., Fr??d??ric C., Simone R., Roland W., ??dith G., Philippine M., Emmanuelle S., Alex C., Aurore M., Christine H., Aim?? G., Matthieu L., Nathalie G., Simone F., Christophe L., Susanne C., Gabriel L., Xavier d.', '2022-09-22', 1),
	('Panne des serveurs', 'Les serveurs sont actuellement en pannes et nous mettons tout en oeuvre pour les rouvrir au plus t??t.<br/>Veuillez nous excuser pour la g??ne occasionn??e.', '2022-09-22', 1),
	('Le match "Petite r??vision - Sujet B5" viens de se terminer !', 'Merci ?? tous les participant qui y ont particip?? du 2022-10-06 au 2022-10-06 !<br/><br/>Liste des participants:<br/>Agathe d., Pierre G., Hortense L., Gabrielle G., Oc??ane G., Jeanne R., Timoth??e D., Denis G., Beno??t B., Antoine L., Thomas d., Philippine M., Margaux L., Virginie d., Nathalie G., Jacques O., Dominique D., Honor?? H., Chantal C., Roland P., Honor?? D., Jules B., Virginie B., Alex P.', '2022-10-06', 1),
	('Le match "Contr??le continue AA1" viens de se terminer !', 'Merci ?? tous les participant qui y ont particip?? du 2022-10-07 au 2022-10-07 !<br/><br/>Liste des participants:<br/>Roland W., Isaac R., Antoine B., Marcelle G., Margaret G., Alexandre M., Christiane L., Marie d., Simone R., Caroline H., Antoine L., C??lina T., Jules B., Matthieu L., Marie C., Josette d., Claire C., Roland P., Alex C., Alphonse V., Xavier d., Constance D., Honor?? H., R??my R., Fr??d??ric C., Aurore M., Simone F., Honor?? D., ??dith G., Alex R., Jos??phine G., Catherine R., ...', '2022-10-07', 1),
	('Notes au prochain examen', 'Des points bonus seront distribu??s aux meilleurs ??l??ves qui participeront aux prochains matchs jusqu\'au jour de l\'examen final.', '2022-10-08', 3),
	('Le match "Dure dure la vie de tomate" viens de se terminer !', 'Merci ?? tous les participant qui y ont particip?? du 2022-10-09 au 2022-10-09 !<br/><br/>Liste des participants:<br/>Andr??e N., Marcelle G., Ren?? d., Virginie B., Jeanne R., Claudine A., R??my R., Marie C., Jacques T., Jules B., Colette W., Raymond B., No??mi F., Fr??d??ric C., Simone R., Roland W., ??dith G., Philippine M., Emmanuelle S., Alex C.', '2022-10-09', 1);

INSERT INTO T_QUIZ_quiz(quiz_id, quiz_title, quiz_image, quiz_enabled, man_id) VALUES
	(1, 'Connaissez vous vraiment ce que vous mangez ?', '0.jpg', 1, 3),
	(2, 'Connaissez vous vraiment ce que vous mangez ? (R??visions)', '0.jpg', 1, 3),
	(3, 'PHY1', '1.jpg', 1, 6),
	(4, 'La terre est notre amie', '2.jpg', 0, 1),
	(5, 'SVT1', '3.jpg', 0, 3),
	(6, 'Du beurre dans les ??pinards', '4.jpg', 1, 9),
	(7, 'test', '5.jpg', 0, 7),
	(8, 'Recap', '6.jpg', 1, 3);

INSERT INTO T_QUESTION_qst(qst_id, qst_content, qst_image, qst_order, qst_enabled, quiz_id) VALUES
	(1, 'Je peux m\'appeler "scarole, iceberg, romaine, roquette"... Je suis une vari??t?? de... ?', NULL, 0, 1, 1),
	(2, 'Quelle pomme de terre ne pousse qu\'au printemps ?', NULL, 1, 1, 1),
	(3, '?? base de quel fruit confectionne-t-on un guacamole ?', NULL, 2, 1, 1),
	(4, 'Le roman d\'Antony Burgess adapt?? au cin??ma par Kubrick est : "XXXX m??canique"', NULL, 3, 0, 1),
	(5, 'Qu\'est ce qui donne la couleur verte aux fruits et l??gumes ?', NULL, 4, 1, 1),
	(6, 'Lequel de ces fruits de printemps a des feuilles toxiques ?', NULL, 5, 1, 1),
	(7, 'Quel fruit est sacr?? pour les Hindous et symbole d\'amour et de fortune ?', NULL, 6, 1, 1),
	(8, 'Quel est l\'autre nom du maracudja ?', NULL, 7, 1, 1),
	(9, 'La pomme de terre est compos?? d???eau ??... ?', NULL, 8, 1, 1),
	(10, 'Quelle pomme de terre ne pousse qu\'au printemps ?', NULL, 0, 1, 2),
	(11, 'Lequel de ces fruits de printemps a des feuilles toxiques ?', NULL, 1, 1, 2),
	(12, 'La pomme de terre est compos?? d???eau ??... ?', NULL, 2, 1, 2),
	(13, 'Quel fruit est sacr?? pour les Hindous et symbole d\'amour et de fortune ?', NULL, 3, 1, 2),
	(14, 'Qu\'est ce qui donne la couleur verte aux fruits et l??gumes ?', NULL, 4, 1, 2),
	(15, 'Quel est l\'autre nom du maracudja ?', NULL, 5, 1, 2),
	(16, 'Je peux m\'appeler "scarole, iceberg, romaine, roquette"... Je suis une vari??t?? de... ?', NULL, 6, 1, 2),
	(17, 'Le roman d\'Antony Burgess adapt?? au cin??ma par Kubrick est : "XXXX m??canique"', NULL, 7, 1, 2),
	(18, '?? base de quel fruit confectionne-t-on un guacamole ?', NULL, 8, 1, 2),
	(19, 'Quel est l\'autre nom de la pomme d\'amour ?', NULL, 0, 1, 3),
	(20, 'Il est vert, rouge ou blanc de qui s\'agit-il ?', NULL, 1, 1, 3),
	(21, 'Qu\'est-ce-qu\'une "Main de buddah" ?', NULL, 2, 1, 3),
	(22, 'Le cornichon est ?', NULL, 3, 1, 3),
	(23, 'Quel fruit est surnomm?? le fruit des dieux ?', NULL, 4, 1, 3),
	(24, 'Le citron est un fruit d\'origine ?', NULL, 5, 1, 3),
	(25, 'Quel pays est le premier producteur de tomate ?', NULL, 6, 1, 3),
	(26, 'Comment la salicorne est-elle cueillie ?', NULL, 0, 1, 4),
	(27, 'Qu\'est-ce qui fait que la r??gion de Saint-Flour se pr??te tout particuli??rement ?? la culture de la lentille blonde ?', NULL, 1, 1, 4),	
	(28, 'La cerise Noire de Meched vient de ?', NULL, 2, 1, 4),
	(29, 'Quel go??t a la courge du marais breton vend??en ?', NULL, 3, 1, 4),
	(30, 'Lors de la r??colte des noix, comment se nomme l\'??tape o?? l???on fait tomber ces fruits secs ?? terre pour les ramasser ?', NULL, 4, 1, 4),
	(31, 'Combien de fois dans l\'ann??e le champ de rhubarbe est-il r??colt?? ? ', NULL, 5, 1, 4),
	(32, 'Comment peut-on ??plucher facilement et simplement les Bonnottes ?', NULL, 6, 1, 4),
	(33, 'Quelle est la qualit?? nutritive essentielle du bleuet ?', NULL, 7, 1, 4),
	(34, 'Qu???est-ce qu\'un substrat ?', NULL, 8, 1, 4),
	(35, 'Que sont des semences hybrides F1 du petit pois violet ?', NULL, 9, 1, 4),
	(36, 'A quelle racine le raifort est-il souvent compar?? ? ', NULL, 10, 1, 4),
	(37, 'Quel pays est le premier producteur de tomate ?', NULL, 0, 1, 5),
	(38, 'Lors de la r??colte des noix, comment se nomme l\'??tape o?? l???on fait tomber ces fruits secs ?? terre pour les ramasser ?', NULL, 1, 1, 5),
	(39, 'Quel fruit est sacr?? pour les Hindous et symbole d\'amour et de fortune ?', NULL, 2, 1, 5),
	(40, 'Quel est l\'autre nom de la pomme d\'amour ?', NULL, 3, 1, 5),
	(41, 'Qu\'est ce qui donne la couleur verte aux fruits et l??gumes ?', NULL, 4, 1, 5),
	(42, 'Comment peut-on ??plucher facilement et simplement les Bonnottes ?', NULL, 5, 1, 5),
	(43, 'Quelle pomme de terre ne pousse qu\'au printemps ?', NULL, 6, 1, 5),
	(44, 'Je peux m\'appeler "scarole, iceberg, romaine, roquette"... Je suis une vari??t?? de... ?', NULL, 7, 1, 5),
	(45, 'Quel est l\'autre nom du maracudja ?', NULL, 8, 1, 5),
	(46, 'Il est vert, rouge ou blanc de qui s\'agit-il ?', NULL, 9, 1, 5),
	(47, 'Quelle est la qualit?? nutritive essentielle du bleuet ?', NULL, 10, 1, 5),
	(48, 'Qu\'est-ce qui fait que la r??gion de Saint-Flour se pr??te tout particuli??rement ?? la culture de la lentille blonde ?', NULL, 11, 1, 5),	
	(49, 'Le cornichon est ?', NULL, 0, 1, 6),
	(50, 'Qu???est-ce qu\'un substrat ?', NULL, 1, 1, 6),
	(51, 'La cerise Noire de Meched vient de ?', NULL, 2, 1, 6),
	(52, 'A quelle racine le raifort est-il souvent compar?? ? ', NULL, 3, 1, 6),
	(53, 'Que sont des semences hybrides F1 du petit pois violet ?', NULL, 4, 0, 6),
	(54, 'Quel fruit est surnomm?? le fruit des dieux ?', NULL, 5, 1, 6),
	(55, '?? base de quel fruit confectionne-t-on un guacamole ?', NULL, 6, 0, 6),
	(56, 'Quel go??t a la courge du marais breton vend??en ?', NULL, 7, 1, 6),
	(57, 'Le citron est un fruit d\'origine ?', NULL, 8, 1, 6),
	(58, 'Comment peut-on ??plucher facilement et simplement les Bonnottes ?', NULL, 0, 1, 7),
	(59, 'Le cornichon est ?', NULL, 1, 1, 7),
	(60, 'Quel go??t a la courge du marais breton vend??en ?', NULL, 2, 0, 7),
	(61, 'La pomme de terre est compos?? d???eau ??... ?', NULL, 3, 1, 7),
	(62, 'Qu\'est-ce-qu\'une "Main de buddah" ?', NULL, 4, 1, 7),
	(63, '?? base de quel fruit confectionne-t-on un guacamole ?', NULL, 5, 1, 7),
	(64, 'Quel fruit est surnomm?? le fruit des dieux ?', NULL, 6, 1, 7),
	(65, 'Lequel de ces fruits de printemps a des feuilles toxiques ?', NULL, 0, 1, 8),
	(66, 'Quel pays est le premier producteur de tomate ?', NULL, 1, 1, 8),
	(67, 'Quel est l\'autre nom du maracudja ?', NULL, 2, 0, 8),
	(68, 'Le citron est un fruit d\'origine ?', NULL, 3, 0, 8),
	(69, 'Quel est l\'autre nom de la pomme d\'amour ?', NULL, 4, 1, 8),
	(70, 'Quelle pomme de terre ne pousse qu\'au printemps ?', NULL, 5, 1, 8),
	(71, 'Quel fruit est sacr?? pour les Hindous et symbole d\'amour et de fortune ?', NULL, 6, 1, 8),
	(72, 'Que sont des semences hybrides F1 du petit pois violet ?', NULL, 7, 1, 8),
	(73, 'Combien de fois dans l\'ann??e le champ de rhubarbe est-il r??colt?? ? ', NULL, 8, 1, 8),
	(74, 'A quelle racine le raifort est-il souvent compar?? ? ', NULL, 9, 1, 8);

INSERT INTO T_ANSWER_ans(ans_content, ans_image, ans_valid, qst_id) VALUES
	('Poivron', NULL, 0, 1), ('Laitue', NULL, 1, 1), ('Curcubitac??', NULL, 0, 1), ('Tomate', NULL, 0, 1),
	('La pomme de terre noisette', NULL, 0, 2), ('La pomme de terre primeur', NULL, 1, 2), ('La pomme de terre grenaille', NULL, 0, 2),
	('Fraise', NULL, 0, 3), ('Tomate', NULL, 0, 3), ('Papaye', NULL, 0, 3), ('Avocat', NULL, 1, 3),
	('Orange', NULL, 1, 4), ('Banane', NULL, 0, 4), ('Carambole', NULL, 0, 4),
	('La chlorophylle', NULL, 1, 5), ('La vitamine A', NULL, 0, 5), ('Le potassium', NULL, 0, 5),
	('L\'amande', NULL, 0, 6), ('La fraise', NULL, 0, 6), ('La rhubarbe', NULL, 1, 6), ('La cerise', NULL, 0, 6),
	('L\'ananas', NULL, 0, 7), ('La banane', NULL, 0, 7), ('La papaye', NULL, 0, 7), ('La mangue', NULL, 1, 7),
	('Le fruit de la passion', NULL, 1, 8), ('Le fruit d??fendu', NULL, 0, 8),
	('20%', NULL, 0, 9), ('40%', NULL, 0, 9), ('60%', NULL, 0, 9), ('80%', NULL, 1, 9),
	('La pomme de terre noisette', NULL, 0, 10), ('La pomme de terre primeur', NULL, 1, 10), ('La pomme de terre grenaille', NULL, 0, 10),
	('L\'amande', NULL, 0, 11), ('La fraise', NULL, 0, 11), ('La rhubarbe', NULL, 1, 11), ('La cerise', NULL, 0, 11),
	('20%', NULL, 0, 12), ('40%', NULL, 0, 9), ('60%', NULL, 0, 12), ('80%', NULL, 1, 12),
	('L\'ananas', NULL, 0, 13), ('La banane', NULL, 0, 13), ('La papaye', NULL, 0, 13), ('La mangue', NULL, 1, 13),
	('La chlorophylle', NULL, 1, 14), ('La vitamine A', NULL, 0, 14), ('Le potassium', NULL, 0, 14),
	('Le fruit de la passion', NULL, 1, 15), ('Le fruit d??fendu', NULL, 0, 15),
	('Poivron', NULL, 0, 16), ('Laitue', NULL, 1, 16), ('Curcubitac??', NULL, 0, 16), ('Tomate', NULL, 0, 16),
	('Orange', NULL, 1, 17), ('Banane', NULL, 0, 17), ('Carambole', NULL, 0, 17),
	('Fraise', NULL, 0, 18), ('Tomate', NULL, 0, 18), ('Papaye', NULL, 0, 18), ('Avocat', NULL, 1, 18),
	('Le melon', NULL, 0, 19), ('La tomate', NULL, 1, 19), ('L\'orange', NULL, 0, 19),
	('Du haricot', NULL, 1, 20), ('Du poivron', NULL, 0, 20), ('Du concombre', NULL, 0, 20),
	('Une vari??t?? de marron', NULL, 0, 21), ('Une vari??t?? de mangue', NULL, 0, 21), ('Une vari??t?? de citron', NULL, 1, 21), ('Une vari??t?? de pomme', NULL, 0, 21),
	('Un concombre', NULL, 1, 22), ('Un poivron', NULL, 0, 22), ('Une courgette', NULL, 0, 22),
	('La framboise', NULL, 0, 23), ('La banane', NULL, 0, 23), ('L\'ananas', NULL, 0, 23), ('La grenade', NULL, 1, 23),
	('Indienne', NULL, 1, 24), ('M??dit??rannenne', NULL, 0, 24), ('Du concombre', NULL, 0, 24),
	('Le maroc', NULL, 0, 25), ('L\'espagne', NULL, 0, 25), ('La chine', NULL, 1, 25),
	('Les pieds de salicorne sont arrach??s', NULL, 0, 26), ('La salicorne est coup??e ?? sa t??te', NULL, 1, 26), ('La salicorne est coup??e ?? son pied', NULL, 0, 26),
	('Son temps chaud, set et venteux', NULL, 1, 27), ('Son climat oc??anique marqu?? par des pluies abondantes', NULL, 0, 27), ('Son fort enneigement pendant la saison hivernal', NULL, 0, 27),
	('Finlande', NULL, 0, 28), ('Iran', NULL, 1, 28), ('Am??rique du Sud', NULL, 0, 28),
	('Un go??t de banane', NULL, 0, 29), ('Un go??t de noisette', NULL, 0, 29), ('Un go??t de ch??taigne', NULL, 1, 29),
	('Le vibrage', NULL, 1, 30), ('Le secouage', NULL, 0, 30), ('Le d??branchage', NULL, 0, 30),
	('Deux fois : printemps et ??t??', NULL, 1, 31), ('Quatre fois : printemps, d??but d\'??t??, d??but d\'automne et fin d\'automne', NULL, 0, 31), ('Cinq fois : d??but de printemps, d??but d\'??t??, fin d\'??t??, mi automne et d??but d\'hiver', NULL, 0, 31),
	('En les ??bouillantant', NULL, 0, 32), ('Avec un ??conome', NULL, 0, 32), ('Avec un sac en toile de jute', NULL, 1, 32),
	('Son apport en vitamine D', NULL, 0, 33), ('Sa teneur en antioxydants', NULL, 1, 33), ('Son apport en om??ga 3', NULL, 0, 33),
	('La peau sup??rieure du champignon', NULL, 0, 34), ('Le pied du champignon', NULL, 0, 34), ('Une base sur laquelle les champignons peuvent se d??velopper', NULL, 1, 34),
	('des semences qui ont exactement le m??me patrimoine g??n??tique', NULL, 1, 35), ('des semences qui poussent tr??s vite', NULL, 0, 35), ('Des semences qui poussent hors sol', NULL, 0, 35),
	('A celle de la topinambour', NULL, 0, 36), ('A celle du wasabi', NULL, 1, 36), ('A celle du bambou', NULL, 0, 36),
	('Le maroc', NULL, 0, 37), ('L\'espagne', NULL, 0, 37), ('La chine', NULL, 1, 37),
	('Le vibrage', NULL, 1, 38), ('Le secouage', NULL, 0, 38), ('Le d??branchage', NULL, 0, 38),
	('L\'ananas', NULL, 0, 39), ('La banane', NULL, 0, 39), ('La papaye', NULL, 0, 39), ('La mangue', NULL, 1, 39),
	('Le melon', NULL, 0, 40), ('La tomate', NULL, 1, 40), ('L\'orange', NULL, 0, 40),
	('La chlorophylle', NULL, 1, 41), ('La vitamine A', NULL, 0, 41), ('Le potassium', NULL, 0, 41),
	('En les ??bouillantant', NULL, 0, 42), ('Avec un ??conome', NULL, 0, 42), ('Avec un sac en toile de jute', NULL, 1, 42),
	('La pomme de terre noisette', NULL, 0, 43), ('La pomme de terre primeur', NULL, 1, 43), ('La pomme de terre grenaille', NULL, 0, 43),
	('Poivron', NULL, 0, 44), ('Laitue', NULL, 1, 44), ('Curcubitac??', NULL, 0, 44), ('Tomate', NULL, 0, 44),
	('Le fruit de la passion', NULL, 1, 45), ('Le fruit d??fendu', NULL, 0, 45),
	('Du haricot', NULL, 1, 46), ('Du poivron', NULL, 0, 46), ('Du concombre', NULL, 0, 46),
	('Son apport en vitamine D', NULL, 0, 47), ('Sa teneur en antioxydants', NULL, 1, 47), ('Son apport en om??ga 3', NULL, 0, 47),
	('Son temps chaud, set et venteux', NULL, 1, 48), ('Son climat oc??anique marqu?? par des pluies abondantes', NULL, 0, 48), ('Son fort enneigement pendant la saison hivernal', NULL, 0, 48),
	('Un concombre', NULL, 1, 49), ('Un poivron', NULL, 0, 49), ('Une courgette', NULL, 0, 49),
	('La peau sup??rieure du champignon', NULL, 0, 50), ('Le pied du champignon', NULL, 0, 50), ('Une base sur laquelle les champignons peuvent se d??velopper', NULL, 1, 50),
	('Finlande', NULL, 0, 51), ('Iran', NULL, 1, 51), ('Am??rique du Sud', NULL, 0, 51),
	('A celle de la topinambour', NULL, 0, 52), ('A celle du wasabi', NULL, 1, 52), ('A celle du bambou', NULL, 0, 52),
	('des semences qui ont exactement le m??me patrimoine g??n??tique', NULL, 1, 53), ('des semences qui poussent tr??s vite', NULL, 0, 53), ('Des semences qui poussent hors sol', NULL, 0, 53),
	('La framboise', NULL, 0, 54), ('La banane', NULL, 0, 54), ('L\'ananas', NULL, 0, 54), ('La grenade', NULL, 1, 54),
	('Fraise', NULL, 0, 55), ('Tomate', NULL, 0, 55), ('Papaye', NULL, 0, 55), ('Avocat', NULL, 1, 55),
	('Un go??t de banane', NULL, 0, 56), ('Un go??t de noisette', NULL, 0, 56), ('Un go??t de ch??taigne', NULL, 1, 56),
	('Indienne', NULL, 1, 57), ('M??dit??rannenne', NULL, 0, 57), ('Du concombre', NULL, 0, 57),
	('En les ??bouillantant', NULL, 0, 58), ('Avec un ??conome', NULL, 0, 58), ('Avec un sac en toile de jute', NULL, 1, 58),
	('Un concombre', NULL, 1, 59), ('Un poivron', NULL, 0, 59), ('Une courgette', NULL, 0, 59),
	('Un go??t de banane', NULL, 0, 60), ('Un go??t de noisette', NULL, 0, 60), ('Un go??t de ch??taigne', NULL, 1, 60),
	('20%', NULL, 0, 9), ('40%', NULL, 0, 61), ('60%', NULL, 0, 61), ('80%', NULL, 1, 61),
	('Une vari??t?? de marron', NULL, 0, 62), ('Une vari??t?? de mangue', NULL, 0, 62), ('Une vari??t?? de citron', NULL, 1, 62), ('Une vari??t?? de pomme', NULL, 0, 62),
	('Fraise', NULL, 0, 63), ('Tomate', NULL, 0, 63), ('Papaye', NULL, 0, 63), ('Avocat', NULL, 1, 63),
	('La framboise', NULL, 0, 64), ('La banane', NULL, 0, 64), ('L\'ananas', NULL, 0, 64), ('La grenade', NULL, 1, 64),
	('L\'amande', NULL, 0, 65), ('La fraise', NULL, 0, 65), ('La rhubarbe', NULL, 1, 65), ('La cerise', NULL, 0, 65),
	('Le maroc', NULL, 0, 66), ('L\'espagne', NULL, 0, 66), ('La chine', NULL, 1, 66),
	('Le fruit de la passion', NULL, 1, 67), ('Le fruit d??fendu', NULL, 0, 67),
	('Indienne', NULL, 1, 68), ('M??dit??rannenne', NULL, 0, 68), ('Du concombre', NULL, 0, 68),
	('Le melon', NULL, 0, 69), ('La tomate', NULL, 1, 69), ('L\'orange', NULL, 0, 69),
	('La pomme de terre noisette', NULL, 0, 70), ('La pomme de terre primeur', NULL, 1, 70), ('La pomme de terre grenaille', NULL, 0, 70),
	('L\'ananas', NULL, 0, 71), ('La banane', NULL, 0, 71), ('La papaye', NULL, 0, 71), ('La mangue', NULL, 1, 71),
	('des semences qui ont exactement le m??me patrimoine g??n??tique', NULL, 1, 72), ('des semences qui poussent tr??s vite', NULL, 0, 72), ('Des semences qui poussent hors sol', NULL, 0, 72),
	('Deux fois : printemps et ??t??', NULL, 1, 73), ('Quatre fois : printemps, d??but d\'??t??, d??but d\'automne et fin d\'automne', NULL, 0, 73), ('Cinq fois : d??but de printemps, d??but d\'??t??, fin d\'??t??, mi automne et d??but d\'hiver', NULL, 0, 73),
	('A celle de la topinambour', NULL, 0, 74), ('A celle du wasabi', NULL, 1, 74), ('A celle du bambou', NULL, 0, 74);

INSERT INTO T_MATCH_match(match_id, match_title, match_code, match_start_date, match_end_date, match_show_answers, match_enabled, quiz_id, man_id) VALUES
	(1, 'Les pros de l\'agriculture', 'EM5WJ92M', '2022-09-20', '2022-09-20', 0, 0, 1, 3),
	(2, 'Les pros de l\'agriculture (R??visions)', 'PMH5AN8S', '2022-09-21', NULL, 1, 1, 2, 3),
	(3, 'Petite r??vision - Sujet B5', 'MAGUSNTI', '2022-10-06', '2022-10-06', 0, 0, 4, 1),
	(4, 'Contr??le continue AA1', 'MP1K54JR', '2022-10-07', '2022-10-07', 0, 0, 5, 3),
	(5, 'Dure dure la vie de tomate', 'LTGA2SFC', '2022-10-09', '2022-10-09', 1, 0, 3, 6),
	(6, 'Pr??paration au milieu professionnel', 'TG35U9ZW', '2022-10-11', NULL, 1, 1, 6, 9),
	(7, 'Dernier test avant examen', 'P82GBH1Y', '2022-10-11', '2023-05-21', 1, 1, 8, 3);

INSERT INTO T_PLAYER_player(player_pseudo, player_score, match_id) VALUES
	('Andr??e N.', 89, 1),
	('Marcelle G.', 80, 1),
	('Ren?? d.', 76, 1),
	('Virginie B.', 99, 1),
	('Jeanne R.', 1, 1),
	('Claudine A.', 52, 1),
	('R??my R.', 22, 1),
	('Marie C.', 38, 1),
	('Jacques T.', 72, 1),
	('Jules B.', 96, 1),
	('Colette W.', 18, 1),
	('Raymond B.', 88, 1),
	('No??mi F.', 10, 1),
	('Fr??d??ric C.', 64, 1),
	('Simone R.', 90, 1),
	('Roland W.', 37, 1),
	('??dith G.', 72, 1),
	('Philippine M.', 58, 1),
	('Emmanuelle S.', 38, 1),
	('Alex C.', 58, 1),
	('Aurore M.', 24, 1),
	('Christine H.', 29, 1),
	('Aim?? G.', 15, 1),
	('Matthieu L.', 19, 1),
	('Nathalie G.', 65, 1),
	('Simone F.', 36, 1),
	('Christophe L.', 41, 1),
	('Susanne C.', 69, 1),
	('Gabriel L.', 36, 1),
	('Xavier d.', 90, 1),
	('Louise B.', 51, 2),
	('Simone R.', 62, 2),
	('Marie d.', 70, 2),
	('Alex C.', 97, 2),
	('Claude d.', 30, 2),
	('Jos??phine G.', 39, 2),
	('Beno??t B.', 49, 2),
	('Alexandre M.', 52, 2),
	('Hortense M.', 46, 2),
	('Ad??la??de D.', 21, 2),
	('Luce R.', 18, 2),
	('Margaux L.', 64, 2),
	('Honor?? D.', 79, 2),
	('Victoire L.', 28, 2),
	('Xavier V.', 97, 2),
	('Marcelle G.', 39, 2),
	('Anouk d.', 35, 2),
	('Antoine L.', 70, 2),
	('Oc??ane G.', 66, 2),
	('Denis G.', 74, 2),
	('Hortense L.', 97, 2),
	('Nathalie G.', 90, 2),
	('Agathe d.', 72, 2),
	('Mich??le L.', 13, 2),
	('Paul J.', 10, 2),
	('Ren?? d.', 38, 2),
	('Thomas d.', 19, 2),
	('Gabriel L.', 21, 2),
	('Fr??d??rique B.', 71, 2),
	('Jules B.', 92, 2),
	('C??lina T.', 11, 2),
	('Raymond B.', 58, 2),
	('??tienne D.', 54, 2),
	('Bertrand d.', 81, 2),
	('Simone F.', 24, 2),
	('Claire C.', 53, 2),
	('Martine L.', 90, 2),
	('Philippine M.', 73, 2),
	('Chantal C.', 75, 2),
	('Isaac R.', 36, 2),
	('Xavier d.', 64, 2),
	('Adrien F.', 62, 2),
	('Agathe d.', 70, 3),
	('Pierre G.', 44, 3),
	('Hortense L.', 91, 3),
	('Gabrielle G.', 68, 3),
	('Oc??ane G.', 52, 3),
	('Jeanne R.', 95, 3),
	('Timoth??e D.', 72, 3),
	('Denis G.', 19, 3),
	('Beno??t B.', 39, 3),
	('Antoine L.', 73, 3),
	('Thomas d.', 10, 3),
	('Philippine M.', 11, 3),
	('Margaux L.', 87, 3),
	('Virginie d.', 90, 3),
	('Nathalie G.', 18, 3),
	('Jacques O.', 65, 3),
	('Dominique D.', 11, 3),
	('Honor?? H.', 26, 3),
	('Chantal C.', 98, 3),
	('Roland P.', 22, 3),
	('Honor?? D.', 53, 3),
	('Jules B.', 21, 3),
	('Virginie B.', 73, 3),
	('Alex P.', 78, 3),
	('Roland W.', 44, 4),
	('Isaac R.', 63, 4),
	('Antoine B.', 21, 4),
	('Marcelle G.', 19, 4),
	('Margaret G.', 69, 4),
	('Alexandre M.', 55, 4),
	('Christiane L.', 82, 4),
	('Marie d.', 39, 4),
	('Simone R.', 68, 4),
	('Caroline H.', 42, 4),
	('Antoine L.', 76, 4),
	('C??lina T.', 21, 4),
	('Jules B.', 73, 4),
	('Matthieu L.', 52, 4),
	('Marie C.', 41, 4),
	('Josette d.', 15, 4),
	('Claire C.', 26, 4),
	('Roland P.', 20, 4),
	('Alex C.', 96, 4),
	('Alphonse V.', 82, 4),
	('Xavier d.', 10, 4),
	('Constance D.', 15, 4),
	('Honor?? H.', 58, 4),
	('R??my R.', 21, 4),
	('Fr??d??ric C.', 10, 4),
	('Aurore M.', 25, 4),
	('Simone F.', 13, 4),
	('Honor?? D.', 64, 4),
	('??dith G.', 47, 4),
	('Alex R.', 87, 4),
	('Jos??phine G.', 11, 4),
	('Catherine R.', 60, 4),
	('Thomas d.', 19, 4),
	('Denis C.', 19, 4),
	('Alex P.', 49, 4),
	('Beno??t B.', 57, 4),
	('Colette W.', 57, 4),
	('Timoth??e D.', 5, 4),
	('Christine G.', 65, 4),
	('Anouk d.', 25, 4),
	('Jean G.', 12, 4),
	('Ren?? d.', 42, 4),
	('No??mi F.', 19, 4),
	('Victoire L.', 63, 4),
	('Adrien F.', 57, 4),
	('Aurore P.', 39, 4),
	('Christine H.', 90, 4),
	('Bertrand d.', 47, 4),
	('Chantal C.', 4, 4),
	('Oc??ane G.', 72, 4),
	('Claude d.', 15, 4),
	('Claudine A.', 30, 4),
	('Andr??e N.', 48, 5),
	('Marcelle G.', 26, 5),
	('Ren?? d.', 24, 5),
	('Virginie B.', 31, 5),
	('Jeanne R.', 59, 5),
	('Claudine A.', 41, 5),
	('R??my R.', 87, 5),
	('Marie C.', 39, 5),
	('Jacques T.', 18, 5),
	('Jules B.', 70, 5),
	('Colette W.', 41, 5),
	('Raymond B.', 51, 5),
	('No??mi F.', 33, 5),
	('Fr??d??ric C.', 67, 5),
	('Simone R.', 51, 5),
	('Roland W.', 99, 5),
	('??dith G.', 93, 5),
	('Philippine M.', 32, 5),
	('Emmanuelle S.', 41, 5),
	('Alex C.', 79, 5),
	('Marie d.', 52, 6),
	('Dominique D.', 74, 6),
	('C??lina T.', 59, 6),
	('Denis G.', 56, 6),
	('Pierre G.', 64, 6),
	('Aurore P.', 53, 6),
	('Catherine R.', 25, 6),
	('Colette W.', 57, 6),
	('Thomas d.', 10, 6),
	('Julien M.', 41, 6),
	('Antoine B.', 51, 6),
	('Claude d.', 28, 6),
	('Martine L.', 36, 6),
	('Gabrielle G.', 30, 6),
	('Jos??phine G.', 59, 6),
	('Lorraine F.', 64, 6),
	('Hortense M.', 71, 6),
	('??dith G.', 47, 6),
	('Jeanne R.', 42, 6),
	('Alexandre M.', 73, 6),
	('Marcelle G.', 23, 6),
	('Timoth??e D.', 45, 6),
	('Antoine L.', 93, 6),
	('Adrien F.', 56, 6),
	('Fr??d??rique B.', 82, 6),
	('Bertrand d.', 13, 6),
	('Aurore M.', 56, 6),
	('Daniel C.', 76, 6),
	('Luce R.', 46, 6),
	('Fr??d??ric C.', 67, 6),
	('No??mi F.', 55, 6),
	('Raymond B.', 67, 6),
	('Aim?? G.', 41, 6),
	('Timoth??e L.', 61, 6),
	('Josette d.', 93, 6),
	('Agathe d.', 75, 6),
	('No??mi F.', 84, 7),
	('Raymond B.', 18, 7),
	('Matthieu L.', 80, 7),
	('Claude d.', 63, 7),
	('Constance D.', 28, 7),
	('Mich??le L.', 55, 7),
	('Antoine L.', 92, 7),
	('Adrien F.', 34, 7),
	('Xavier V.', 85, 7),
	('Caroline H.', 20, 7),
	('Thomas L.', 98, 7),
	('Marie d.', 25, 7),
	('Andr?? G.', 37, 7),
	('Gabriel L.', 29, 7),
	('Simone F.', 67, 7),
	('Alex P.', 60, 7),
	('Daniel C.', 17, 7),
	('R??my R.', 60, 7),
	('Beno??t B.', 86, 7),
	('??dith G.', 6, 7),
	('Jules B.', 43, 7),
	('Julien M.', 11, 7),
	('Luc D.', 46, 7),
	('Christine G.', 58, 7),
	('Claire C.', 78, 7),
	('Roland W.', 71, 7),
	('Timoth??e D.', 95, 7),
	('Aim?? G.', 89, 7),
	('Jean G.', 19, 7),
	('Alex R.', 57, 7);