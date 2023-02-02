# Matchs:
# 5)
SELECT _question.qst_id, _question.qst_content, _answer.ans_id, _answer.ans_content
FROM T_MATCH_match
JOIN T_QUIZ_quiz USING(quiz_id)
JOIN T_QUESTION_qst AS _question USING(quiz_id)
JOIN T_ANSWER_ans AS _answer USING(qst_id)
WHERE match_id = 2 && match_show_answers = 1 && ans_valid = 1;

# 6)
SELECT ans_valid
FROM T_ANSWER_ans
WHERE ans_id = 1;

# 7)
UPDATE T_PLAYER_player
SET player_score = player_score + 1
WHERE player_pseudo = 'Adrien F.' && match_id = 2;

# 8)
SELECT player_score
FROM T_PLAYER_player
WHERE player_pseudo = 'Adrien F.' && match_id = 2;


# Quiz:
# 3)
SELECT * FROM T_QUIZ_quiz;

# 4)
SELECT
	_quiz.quiz_title,
    _quiz_man.man_pseudo AS quiz_author,
    _match.match_title,
    _match_man.man_pseudo AS match_author
FROM T_QUIZ_quiz AS _quiz
JOIN T_MANAGER_man AS _quiz_man ON _quiz.man_id = _quiz_man.man_id
LEFT OUTER JOIN T_MATCH_match AS _match ON _match.man_id = _quiz.man_id
LEFT OUTER JOIN T_MANAGER_man AS _match_man ON _match_man.man_id = _match.man_id;

# 5)
SELECT * FROM T_QUIZ_quiz WHERE man_id = 3;

# 6)
# SELECT T_QUIZ_quiz.* FROM T_QUIZ_quiz JOIN T_MANAGER_man USING(man_id) WHERE man_role != 'F';
SELECT * FROM T_QUIZ_quiz WHERE man_id = 1;

# 7)
SELECT _quiz.*, _match.*
FROM T_MANAGER_man
JOIN T_QUIZ_quiz AS _quiz USING(man_id)
LEFT OUTER JOIN T_MATCH_match AS _match USING(quiz_id)
WHERE man_pseudo = 'remyo' && man_pw = 'a625af4612f08fee465e3b5976567fe6fa0151bd8167c55641cbaf7314fa12de20cad6f6c330345b6ea3f302fe6cab9c1e19c675f0bec7b2f20e04b4844ff172';


# Matchs:
# 7)
INSERT INTO T_MATCH_match(match_title, match_code, match_show_answers, match_enabled, quiz_id, man_id) VALUES
	('mon nouveau match', 'J9LJU5GZ', 0, 1, 1, 3);

# 8)
UPDATE T_MATCH_match
SET match_end_date = CURDATE()
WHERE match_id = 1;

# 9)
DELETE FROM T_PLAYER_player WHERE match_id = 7;
DELETE FROM T_MATCH_match WHERE match_id = 7;

# 10)
UPDATE T_MATCH_match
SET match_enabled = (match_enabled = 0)
WHERE match_id = 1;

# 11)
DELETE FROM T_PLAYER_player WHERE match_id = 1;

UPDATE T_MATCH_match
SET
	match_start_date = NULL,
	match_end_date = NULL
WHERE match_id = 1;