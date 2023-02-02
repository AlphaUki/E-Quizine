# Actualités: (En tant que visiteur)
# 1)
SELECT new_id, new_title, new_content, new_date, man_pseudo, man_pw  FROM T_NEWS_new JOIN T_MANAGER_man USING(man_id);
# 2)
SELECT * FROM T_NEWS_new WHERE new_id = 1;
# 3)
SELECT * FROM T_NEWS_new ORDER BY new_id DESC LIMIT 5;
# 4)
SELECT * FROM T_NEWS_new WHERE new_title LIKE '%Merci%' || new_content LIKE '%Merci%';
# 5)
SELECT new_id, new_title, new_content, new_date, man_pseudo, man_pw FROM T_NEWS_new JOIN T_MANAGER_man USING(man_id) WHERE new_date = '2022-10-01';


# Matchs: (En tant que joueur)
# 1) (le code d'un match ne peut être null ou vide -> CHAR(8) NOT NULL)
SELECT (match_code IS NOT NULL && match_code LIKE '813%') FROM T_MATCH_match;
# 2)
INSERT INTO T_PLAYER_player(player_pseudo, player_score, match_id) VALUES ('MonJoueur', 0, 6);
# 3)
SELECT (COUNT(*) > 0) FROM T_PLAYER_player WHERE player_pseudo = 'MonJoueur' && match_id = 6;
# 4)
SELECT qst_id, qst_content, ans_id, ans_content
FROM T_MATCH_match
JOIN T_QUESTION_qst USING(quiz_id)
JOIN T_ANSWER_ans USING(qst_id)
WHERE match_id = 1;


# Actialités: (En tant que formateur/administrateur)
# 1)
SELECT T_NEWS_new.* FROM T_NEWS_new JOIN T_MANAGER_man USING(man_id) WHERE man_pseudo = 'responsable';


# Profils: (En tant que formateur/administrateur)
# 1)
SELECT * FROM T_PROFILE_pfl;
# 2)
SELECT T_PROFILE_pfl.* FROM T_PROFILE_pfl WHERE pfl_role IN ('A', 'F');
# 3)
SELECT (COUNT(*) > 0) FROM T_MANAGER_man WHERE man_pseudo = 'responsable' && man_pw = CONVERT(FN_HASH_PW('resp22_ZUIQ') USING ascii);
# 4)
SELECT T_PROFILE_pfl.*
FROM T_PROFILE_pfl
JOIN T_MANAGER_man USING(man_id)
WHERE man_pseudo = 'responsable' && man_pw = '6917481445f718eb9c0b5ade9a27bf77524e8c8b1c38c754225ef41b67e7a67e203bea13808802f144f9d6d63f8287432e7a35662e8e94fe9fea0ebff5e607e0';
# 5)
SELECT man_pseudo, man_pw, pfl_active
FROM T_PROFILE_pfl
JOIN T_MANAGER_man USING(man_id);


# Quiz: (En tant que formateur)
# 1)
SELECT * FROM T_QUESTION_qst JOIN T_ANSWER_ans USING(qst_id) WHERE quiz_id = 1;
# 2)
SELECT COUNT(qst_id) FROM T_QUESTION_qst WHERE quiz_id = 1;


# Matchs: (En tant que formateur)
# 1)
SELECT T_QUESTION_qst.*, T_ANSWER_ans.*
FROM T_MATCH_match
JOIN T_QUESTION_qst USING(quiz_id)
JOIN T_ANSWER_ans USING(qst_id)
WHERE match_code = 'EM5WJ92M';
# 2)
SELECT COUNT(*) FROM T_PLAYER_player WHERE match_id = 1;
# 3) SUM pour le total ou AVG pour la moyenne
SELECT SUM(player_score) FROM T_PLAYER_player WHERE match_id = 1;
# 4)
SELECT player_score, player_pseudo FROM T_PLAYER_player WHERE match_id = 1;
# 5)
SELECT *
FROM T_MATCH_match
JOIN T_MANAGER_man USING(man_id)
WHERE man_pseudo = 'thomandjerry' && man_pw = 'ad8c85709213b04cc58876a9d98dbc6bbe19c00323fb016fd7acfe2318a0e203e9db1f269cfe63b99776a480ecd3d2bc29aa7e989b099741807ab2263d944d93';
# 6)
SELECT * FROm T_MATCH_match WHERE quiz_id = 1;